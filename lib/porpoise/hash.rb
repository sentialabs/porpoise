module Porpoise
  module Hash
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
      o.value[field].to_i += increment.to_i
      o.save
      o.value[field]
    end

    def hincrbyfloat(key, field, increment)
      o = find_stored_object(key)
      o.value[field].to_f += increment.to_f
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
      o.map { |k, v| v if fields.include?(k) }
    end

    def hmset(key, *fields_and_values)
      o = find_stored_object(key)
      set_values = Hash[*fields_and_values]
      o.value.keys.each do |k|
        o.value[k] = set_values[k] if set_values.has_key?(k)
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

    def find_stored_object(key, raise_on_not_found = true)
      o = KeyValueObject.where(key: key).first
      
      if raise_on_not_found
        raise Porpoise::KeyNotFound.new("Key #{key} could not be found") if o.nil?
        raise Porpoise::TypeMismatch.new("Key #{key} is not a hash") unless o.value.is_a?(Hash)
      else
        o = KeyValueObject.new(key: key, value: Hash.new)
      end

      return o
    end
  end
end
