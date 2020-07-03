module ActiveSupport
  module Cache
    class PorpoiseStore < Store
      # The maximum number of objects to store in
      # the short life cache.
      SHORT_LIFE_CACHE_SIZE = 5000

      # The number of seconds items in the short
      # cache are allowed to live.
      SHORT_LIFE_CACHE_TIME = 5

      attr_reader :namespace
      attr_reader :slc, :slt # short life cache

      def initialize(options = {})
        @namespace = options.fetch(:namespace, "active-support-cache").to_s
      end

      def cleanup(options = nil)
        short_mem_reset

        total_deleted_items_count = 0

        Porpoise::KeyValueObject.retry_lock_error(20) do
          query = 'DELETE FROM key_value_objects WHERE `key` LIKE ? AND expiration_date IS NOT NULL AND expiration_date < ? LIMIT 200'
          sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, [query, "#{@namespace}:%", Time.now])

          deleted_items_count = 1
          while deleted_items_count > 0 do
            deleted_items_count = Porpoise::KeyValueObject.connection.send(:delete, sanitized_query)
            total_deleted_items_count += deleted_items_count
          end
        end

        return total_deleted_items_count
      end

      def clear(options = nil)
        short_mem_reset
        Porpoise::KeyValueObject.retry_lock_error(20) do
          Porpoise::KeyValueObject.where(["`key` LIKE ?", "#{@namespace}:%"]).pluck(:key).in_groups_of(150) do |object_keys|
            Porpoise::KeyValueObject.where(key: object_keys).delete_all
          end
        end
      end

      def decrement(name, amount, options = nil)
        Porpoise.with_namespace(@namespace) {
          v = read(name)
          v = v.to_i - amount.to_i
          write(name, v, options)
          v
        }
      end

      def delete(name, options = nil)
        Porpoise.with_namespace(@namespace) {
          short_mem_del(name)
          Porpoise::Key.del(name)
        }
      end

      def delete_matched(matcher, options = nil)
        short_mem_reset
        Porpoise.with_namespace(@namespace) { Porpoise::Key.del_matched(matcher) }
      end

      def exists?(name, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::Key.exists(name) == 1 }
      end

      def fetch(name, options = nil)
        res = read(name)
        if res.nil? && block_given?
          res = yield(name)
          write(name, res, options)
        end
        return res
      end

      def fetch_multi(*names)
        res = read_multi(*names)
        return res unless block_given?

        mres = {}
        res.each do |name, value|
          if value.nil?
            mres[name] = yield(name)
            write(name, mres[name])
          else
            mres[name] = value
          end
        end

        return mres
      end

      def increment(name, amount, options = nil)
        Porpoise.with_namespace(@namespace) {
          v = read(name)
          v = v.to_i + amount.to_i
          write(name, v, options)
          v
        }
      end

      def read(name, options = nil)
        val = Porpoise.with_namespace(@namespace) {
          short_mem_read(name) { Porpoise::String.get(name) }
        }

        begin
          return val.nil? ? nil : Marshal.load(val)
        rescue TypeError
          return val
        rescue ArgumentError => e
          if e.message =~ /marshal data too short/
            return nil
          else
            raise e
          end
        end
      end

      def read_multi(*names)
        result = {}
        names.each do |name|
          val = Porpoise.with_namespace(@namespace) {
            short_mem_read(name) { Porpoise::String.get(name) }
          }
          begin
            result[name] = (val.nil? ? nil : Marshal.load(val))
          rescue TypeError
            result[name] = val
          rescue ArgumentError => e
            if e.message =~ /marshal data too short/
              return nil
            else
              raise e
            end
          end
        end
        return result
      end

      def write(name, value, options = nil)
        options = {} if options.nil?
        Porpoise.with_namespace(@namespace) {
          short_mem_write(name, value, options) {
            Porpoise::String.set(name, Marshal.dump(value), options.fetch(:expires_in, nil))
          }
        }
      end

      private

      def short_mem_reset
        @slc = {}
        @slt = {}
      end

      def short_mem_write(name, value, options = nil)
        @slc ||= {}
        @slt ||= {}

        # Do not write the short life cache if an item has an expiration time
        unless options && options.has_key?(:expires_in)
          @slt[name] = Time.now.to_i
          @slc[name] = value

          # Remove the oldest entries when cache gets to big
          if @slt.keys.size >= SHORT_LIFE_CACHE_SIZE
            kk = @slt.sort_by { |k,v| value }.shift(@slt.keys.size - SHORT_LIFE_CACHE_SIZE).map { |kv| kv[0] }
            kk.each do |k|
              @slt.delete(k)
              @slc.delete(k)
            end
          end
        end

        yield if block_given?
      end

      def short_mem_read(name)
        @slc ||= {}
        @slt ||= {}
        v = @slc.fetch(name, nil)

        # Remove dead items
        if v && (@slt[name] + SHORT_LIFE_CACHE_TIME) < Time.now.to_i
          @slc.delete(name)
          @slt.delete(name)
          v = nil
        end

        if v.nil? && block_given?
          v = yield
          short_mem_write(name, v) unless v.nil?
        end

        return v
      end

      def short_mem_del(name)
        @slc ||= {}
        @slt ||= {}

        @slc.delete(name)
        @slt.delete(name)
      end
    end
  end
end
