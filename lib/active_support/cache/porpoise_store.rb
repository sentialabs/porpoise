module ActiveSupport
  module Cache
    class PorpoiseStore < Store
      def cleanup(options = nil)
        Porpoise::KeyValueObject.where(["expiration_date IS NOT NULL AND expiration_date < ?", Time.now]).delete_all
      end

      def clear(options = nil)
        Porpoise::KeyValueObject.delete_all
      end

      def decrement(name, amount, options = nil)
        Porpoise::String.decrby(name, amount)
      end

      def delete(name, options = nil)
        Porpoise::Key.del(name)
      end

      def delete_matched(matcher, options = nil)
        Porpoise::Key.del_matched(matcher)
      end

      def exists?(name, options = nil)
        Porpoise::Key.exists(name)
      end

      def fetch(name, options = nil)
        res = read(name)
        if res.nil? && block_given?
          res = yield
          write(nama, res)
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
          end
        end

        return mres
      end

      def increment(name, amount, options = nil)
        Porpoise::String.incrby(name, amount)
      end

      def read(name, options = nil)
        val = Porpoise::String.get(name)
        return val.nil? ? nil : JSON.decode(val)
      end

      def read_multi(*names)
        result = {}
        names.each do |name|
          val = Porpoise::String.get(name)
          result[name] = val.nil? ? nil : JSON.decode(val)
        end
        return result
      end

      def write(name, value, options = nil)
        Porpoise::String.set(name, value.to_json)
      end
    end
  end
end
