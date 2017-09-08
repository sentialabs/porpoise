module Porpoise
  module Key
    class << self
      def del(key, *other_keys)
        o = find_stored_object(key)
        aff = 0

        unless o.nil?
          o.delete
          aff += 1
        end 
        
        if other_keys.any?
          aff += Porpoise::KeyValueObject.where(key: other_keys).delete_all
        end

        return aff
      end

      def del_matched(matcher)
        matcher = matcher.gsub("*", "%")
        Porpoise::KeyValueObject.where(["`key` LIKE ?", matcher]).delete_all
      end

      def dump(key)
        o = find_stored_object(key)
        return nil if o.nil?

        o.value.to_json
      end

      def exists(key, *other_keys)
        all_keys = [key].concat(other_keys)
        Porpoise::KeyValueObject.where(key: all_keys).count
      end

      def expire(key, seconds)
        o = find_stored_object(key)
        return 0 if o.nil?
        o.expiration_date = (Time.now + seconds)

        return o.save ? 1 : 0
      end

      def persist(key)
        o = find_stored_object(key)
        return 0 if o.nil? || o.expiration_date.blank?

        o.expiration_date = nil
        o.save ? 1 : 0
      end

      def rename(key, newkey)
        o = find_stored_object(key)
        return false if o.nil?
        o.key = key

        o.save
      end

      def type(key)
        o = find_stored_object(key)
        return false if o.nil?
        return o.data_type
      end

      def keys(key_name_or_search_string)
        if key_name_or_search_string.include?('*')
          return Porpoise::KeyValueObject.where(['`key` LIKE ?', key_name_or_search_string.gsub('*', '%')]).pluck(:key)
        else
          return Porpoise::KeyValueObject.where(key: key_name_or_search_string).pluck(:key)
        end
      end

      private
      
      def find_stored_object(key, raise_on_not_found = false)
        o = Porpoise::KeyValueObject.where(key: key).first
        
        if raise_on_not_found
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found") if o.nil?
        end

        return o
      end
    end
  end
end
