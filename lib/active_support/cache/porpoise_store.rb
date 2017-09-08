module ActiveSupport
  module Cache
    class PorpoiseStore < Store
      attr_reader :namespace

      def initialize(options = {})
        @namespace = options.fetch(:namespace, "").to_s
      end

      def cleanup(options = nil)
        Porpoise::KeyValueObject.where(["expiration_date IS NOT NULL AND expiration_date < ?", Time.now]).delete_all
      end

      def clear(options = nil)
        Porpoise::KeyValueObject.delete_all
      end

      def decrement(name, amount, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::String.decrby(name, amount) }
      end

      def delete(name, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::Key.del(name) }
      end

      def delete_matched(matcher, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::Key.del_matched(matcher) }
      end

      def exists?(name, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::Key.exists(name) }
      end

      def fetch(name, options = nil)
        res = read(name)
        if res.nil? && block_given?
          res = yield(name)
          write(name, res)
        end
        return res
      end

      def fetch_multi(*names)
        res = read_multi(names)
        return res unless block_given?

        mres = {}
        res.each do |name, value|
          if value.nil?
            mres[name] = yield(name)
            write(name, mres[name])
          end
        end

        return mres
      end

      def increment(name, amount, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::String.incrby(name, amount) }
      end

      def read(name, options = nil)
        val = Porpoise.with_namespace(@namespace) { Porpoise::String.get(name) }
        return val.nil? ? nil : Marshal.load(val)
      end

      def read_multi(*names)
        result = {}
        names.each do |name|
          val = Porpoise.with_namespace(@namespace) { Porpoise::String.get(name) }
          result[name] = val.nil? ? nil : Marshal.load(val)
        end
        return result
      end

      def write(name, value, options = nil)
        Porpoise.with_namespace(@namespace) { Porpoise::String.set(name, Marshal.dump(value)) }
      end
    end
  end
end
