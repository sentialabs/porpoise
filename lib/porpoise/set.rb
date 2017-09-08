module Porpoise
  module Set
    class << self
      def sadd(key, *members)
        o = find_stored_object(key)
        previous_set = o.value.dup
        o.value = o.value.concat(members).uniq
        o.save

        o.value.size - previous_set.size
      end

      def scard(key)
        o = find_stored_object(key)
        o.size
      end

      def sdiff(key, *other_keys)
        o = find_stored_object(key)
        current_set = o.value

        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set = current_set - oo[ok].value
        end
        current_set
      end

      def sdiffstore(destination, key, *other_keys)
        o = find_stored_object(key)
        
        current_set = o.value
        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set = current_set - oo[ok].value
        end

        no = find_stored_object(destination)
        no.value = current_set
        no.save
        no.value.size
      end

      def sinter(key, *other_keys)
        o = find_stored_object(key)
        current_set = o.value

        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set = current_set & oo[ok].value
        end
        return current_set
      end

      def sinterstore(destination, key, *other_keys)
        o = find_stored_object(key)
        
        current_set = o.value
        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set = current_set & oo[ok].value
        end

        no = find_stored_object(destination)
        no.value = current_set
        no.save
        no.value.size
      end

      def sismember(key, member)
        o = find_stored_object(key)
        return o.value.include?(member) ? 1 : 0
      end

      def smembers(key)
        o = find_stored_object(key)
        return o.value
      end

      def smove(source, destination, member)
        Porpoise::KeyValueObject.transaction do
          src = find_stored_object(source)
          dst = find_stored_object(destination)
          
          ele = src.delete(member)
          return 0 if ele.nil?

          dst.value << ele unless dst.value.include?(ele)
          res = dst.save

          return (ele && res) ? 1 : 0
        end
      end

      def spop(key, count = 1)
        o = find_stored_object(key)
        return nil if o.new_record?
        pd = o.value.dup.shuffle.pop(count)

        o.value = o.value.reject { |v| pd.include?(v) }
        o.save

        return pd
      end

      def srandmember(key, count = 1)
        o = find_stored_object(key)
        return [] if o.new_record?

        return o.value.sample(count)
      end

      def srem(key, member, *other_members)
        o = find_stored_object(key)
        return 0 if o.new_record?

        previous_set = o.value.dup
        o.value = o.value.reject { |v| v == member || other_members.include?(member) }
        o.save

        previous_set - o.value
      end

      def sunion(keys, *other_keys)
        o = find_stored_object(key)
        current_set = o.value.dup

        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set.concat(oo[ok].value)
        end
        current_set.uniq
      end

      def sunionstore(destination, key, *other_keys)
        o = find_stored_object(key)
        
        current_set = o.value
        oo = Porpoise::KeyValueObject.where(key: other_keys).all.index_by(&:key)
        other_keys.each do |ok|
          next unless oo.has_key?(ok)
          current_set = current_set.concat(oo[ok].value)
        end

        no = find_stored_object(destination)
        no.value = current_set
        no.save
        no.value.size
      end

      private
      
      def find_stored_object(key, raise_on_not_found = false)
        o = Porpoise::KeyValueObject.where(key: key).first
        
        if raise_on_not_found
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found") if o.nil?
          raise Porpoise::TypeMismatch.new("Key #{key} is not an array") unless o.value.is_a?(::Array)
        elsif o.nil?
          o = Porpoise::KeyValueObject.new(key: key, value: ::Array.new)
        end

        return o
      end
    end
  end
end
