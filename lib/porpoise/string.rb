module Porpoise
  module String
    class << self
      def append(key, value)
        o = find_stored_object(key)
        o.value += value
        o.save

        o.value.size
      end

      def decr(key)
        o = find_stored_object(key)
        o.value = (o.value.to_i - 1).to_s
        o.save

        o.value
      end

      def decrby(key, decrement)
        o = find_stored_object(key)
        o.value = (o.value.to_i - decrement.to_i).to_s
        o.save

        o.value
      end

      def get(key)
        o = find_stored_object(key)
        return nil if o.new_record?
        o.value
      end

      def getrange(key, first, last)
        o = find_stored_object(key)
        return nil if o.new_record?
        o.value[first..last]
      end

      def getset(key, value)
        o = find_stored_object(key)
        return nil if o.new_record?
        
        ov = o.value
        o.value = value
        o.save

        return ov
      end

      def incr(key)
        o = find_stored_object(key)
        o.value = (o.value.to_i + 1).to_s
        o.save

        o.value
      end

      def incrby(key, increment)
        o = find_stored_object(key)
        o.value = (o.value.to_i + increment.to_i).to_s
        o.save

        o.value
      end

      def mget(key, *other_keys)
        o = find_stored_object(key)
        values = o.new_record? ? [nil] : [o.value]
        other_keys = other_keys.map { |k| Porpoise::key_with_namespace(k) }

        oo = Porpoise::KeyValueObject.not_expired.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          values << (oo.has_key?(ok) ? oo[ok].value : nil)
        end

        return values
      end

      def mset(key, value, *other_keys_and_values)
        Porpoise::KeyValueObject.transaction do
          o = find_stored_object(key)
          o.value = value
          o.save

          new_keys_and_values = ::Hash[*other_keys_and_values]
          new_keys_and_values.each do |nk, nv|
            oo = find_stored_object(nk)
            oo.value = nv
            oo.save
          end
        end
        
        return true
      end

      def setex(key, seconds, value)
        o = find_stored_object(key)
        o.value = value
        o.expiration_date = Time.now + seconds
        return o.save
      end

      def set(key, value, ex = nil, px = nil, nx_or_xx = nil)
        o = find_stored_object(key, false)
        o.value = value.to_s

        if nx_or_xx
          if nx_or_xx.downcase.eql?('nx')
            return nil if !o.new_record?
          elsif nx_or_xx.downcase.eql?('xx')
            return nil if o.new_record?
          end
        end

        o.expiration_date = (Time.now + ex) unless ex.nil?
        o.expiration_date = (Time.now + (px / 1000)) unless px.nil?

        o.save
      end

      def strlen(key)
        o = find_stored_object(key)
        o.value.size
      end

      private
      
      def find_stored_object(key,
        raise_on_type_mismatch = true,
        raise_on_not_found = false)
        
        key = Porpoise::key_with_namespace(key)
        o = Porpoise::KeyValueObject.where(key: key).first
        
        if raise_on_type_mismatch && !o.nil? && o.data_type != 'String'
          raise Porpoise::TypeMismatch.new(
            "Key #{key} is not of type String (is #{o.data_type})"
          )
        end

        if raise_on_not_found && o.nil?
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found")
        elsif o.nil?
          o = Porpoise::KeyValueObject.new(key: key, value: ::String.new)
        elsif o.expired?
          o.delete
          o = Porpoise::KeyValueObject.new(key: key, value: ::String.new)
        end

        return o
      end
    end
  end
end
