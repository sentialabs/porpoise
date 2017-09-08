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
        o.value.to_i -= 1
        o.save

        o.value
      end

      def decrby(key, decrement)
        o = find_stored_object(key)
        o.value.to_i -= decrement
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
        o.value[last..first]
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
        o.value.to_i += 1
        o.save

        o.value
      end

      def incrby(key, increment)
        o = find_stored_object(key)
        o.value.to_i += increment
        o.save

        o.value
      end

      def mget(key, *other_keys)
        o = find_stored_object(key)
        values = o.new_record? ? [nil] : o.value

        oo = KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          values << oo.has_key?(ok) ? oo[k].value : nil
        end

        return values
      end

      def mset(key, value, *other_keys_and_values)
        KeyValueObject.transaction do
          o = find_stored_object(key)
          o.value = value
          o.save

          new_keys_and_values = Hash[*other_keys_and_values]
          new_keys_and_values.each do |nk, nv|
            oo = find_stored_object(nk)
            oo.value = nk
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
        o = find_stored_object(key)
        o.value = value

        if nx_or_xx
          if nx_or_xx.eql?('NX')
            return nil && !o.new_record?
          elsif nx_or_xx.eql?('XX')
            return nil && o.new_record?
          end
        end

        o.expiration_date = (Time.now + seconds) unless ex.nil?
        o.expiration_date = (Time.now + (px / 1000)) unless ex.nil?

        o.save
      end

      def strlen(key)
        o = find_stored_object(key)
        o.value.size
      end

      private
      
      def find_stored_object(key, raise_on_not_found = false)
        o = KeyValueObject.where(key: key).first
        
        if raise_on_not_found
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found") if o.nil?
          raise Porpoise::TypeMismatch.new("Key #{key} is not a hash") unless o.value.is_a?(String)
        else
          o = KeyValueObject.new(key: key, value: String.new)
        end

        return o
      end
    end
  end
end
