module Porpoise
  module Hash
    class << self
      def hdel(key, *fields)
        o = find_stored_object(key)
        current_keys = o.value.keys.size
        o.value = o.value.delete_if { |k,v| fields.include?(k) }
        o.save
      
        return current_keys - o.value.keys.size
      end

      def hexists(key, field)
        o = find_stored_object(key)
        o.value.has_key?(field) ? 1 : 0
      end

      def hget(key, field)
        o = find_stored_object(key)
        o.value.fetch(field, nil)
      end

      def hgetall(key)
        o = find_stored_object(key)
        o.value
      end

      def hincrby(key, field, increment)
        o = find_stored_object(key)
        o.value[field] += increment.to_i
        o.save
        o.value[field]
      end

      def hincrbyfloat(key, field, increment)
        o = find_stored_object(key)
        o.value[field] = (o.value[field] + increment.to_f).round(5)
        o.save
        o.value[field]
      end

      def hkeys(key)
        o = find_stored_object(key)
        o.value.keys
      end

      def hlen(key)
        o = find_stored_object(key)
        o.value.keys.size
      end

      def hmget(key, *fields)
        o = find_stored_object(key)
        fields.map { |f| o.value.fetch(f, nil) }
      end

      def hmset(key, *fields_and_values)
        o = find_stored_object(key)
        set_values = ::Hash[*fields_and_values]

        set_values.keys.each do |k|
          o.value[k] = set_values[k]
        end
        o.save
      end

      def hset(key, field, value)
        o = find_stored_object(key)
        current_value = o.value.fetch(field, "")
        o.value[field] = value
        
        if o.save
          return current_value == value ? 0 : 1
        else
          return 0
        end
      end

      def hsetnx(key, field, value)
        o = find_stored_object(key)
        ahk = o.value.has_key?(field)
        o.value[field] = value unless ahk
        
        if o.save
          return ahk ? 0 : 1
        else
          return 0
        end
      end

      def hstrlen(key, field)
        o = find_stored_object(key)
        o.value.fetch(field, "").to_s.size
      end

      def hvals(key)
        o = find_stored_object(key)
        o.value.values
      end

      private

      def find_stored_object(key,
          raise_on_type_mismatch = true,
          raise_on_not_found = false)
        
        key = Porpoise::key_with_namespace(key)
        o = Porpoise::KeyValueObject.not_expired.where(key: key).first
        
        if raise_on_type_mismatch && !o.nil? && o.data_type != 'Hash'
          raise Porpoise::TypeMismatch.new(
            "Key #{key} is not of type Hash (is #{o.data_type})"
          )
        end

        if raise_on_not_found && o.nil?
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found")
        elsif o.nil?
          o = Porpoise::KeyValueObject.new(key: key, value: ::Hash.new)
        elsif o.expired?
          Porpoise::KeyValueObject.retry_lock_error(20) { o.delete }
          o = Porpoise::KeyValueObject.new(key: key, value: ::Hash.new)
        end

        return o
      end
    end
  end
end
