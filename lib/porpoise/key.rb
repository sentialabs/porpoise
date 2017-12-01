module Porpoise
  module Key
    class << self
      def del(key, *other_keys)
        o = find_stored_object(key)
        aff = 0

        unless o.nil?
          Porpoise::KeyValueObject.retry_lock_error(20) { o.delete }
          aff += 1
        end 
        
        if other_keys.any?
          aff += Porpoise::KeyValueObject.not_expired.
            where(key: other_keys.map { |k| Porpoise::key_with_namespace(k) }).
            delete_all
        end

        return aff
      end

      def del_matched(matcher)
        matcher = Porpoise::key_with_namespace(matcher.gsub("*", "%"))
        Porpoise::KeyValueObject.retry_lock_error(20) do
          Porpoise::KeyValueObject.not_expired.where(["`key` LIKE ?", matcher]).delete_all
        end
      end

      def dump(key)
        o = find_stored_object(key)
        return nil if o.nil?

        Marshal.dump(o.value)
      end

      def exists(key, *other_keys)
        all_keys = [key].concat(other_keys)
        Porpoise::KeyValueObject.not_expired.
          where(key: all_keys.map { |k| Porpoise::key_with_namespace(k) }).
          count
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
        o = find_stored_object(key, true)
        no = find_stored_object(newkey)
        
        unless no.nil?
          Porpoise::KeyValueObject.retry_lock_error(20) { no.delete }
        end

        no = o.dup
        no.key = newkey
        Porpoise::KeyValueObject.retry_lock_error(20) {  o.delete }

        no.save
      end

      def type(key)
        o = find_stored_object(key)
        return false if o.nil?
        return o.data_type
      end

      def ttl(key)
        o = find_stored_object(key)
        return -2 if o.nil?
        return -1 if o.expiration_date.nil?
        return o.expiration_date - Time.now
      end

      def keys(key_or_search_string)
        if key_or_search_string.include?('*')
          param = Porpoise::key_with_namespace(key_or_search_string.gsub('*', '%'))
          ks = Porpoise::KeyValueObject.not_expired.
            where(['`key` LIKE ?', param]).
            pluck(:key)
          
            return Porpoise::namespace? ? ks.map { |k| k.sub("#{Porpoise::namespace}:", '') } : ks
        else
          param = Porpoise::key_with_namespace(key_or_search_string)
          ks = Porpoise::KeyValueObject.not_expired.where(key: param).pluck(:key)
          return Porpoise::namespace? ? ks.map { |k| k.sub("#{Porpoise::namespace}:", '') } : ks
        end
      end

      private
      
      def find_stored_object(key, raise_on_not_found = false)
        key = Porpoise::key_with_namespace(key)
        o = Porpoise::KeyValueObject.where(key: key).first

        if raise_on_not_found && o.nil?
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found")
        elsif !o.nil? && o.expired?
          Porpoise::KeyValueObject.retry_lock_error(20) { o.delete }
          o = nil
          raise Porpoise::KeyNotFound.new("Key #{key} could not be found") if raise_on_not_found
        end

        return o
      end
    end
  end
end
