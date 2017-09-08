module Porpoise
  module Util
    class << self
      def ping
        return !Porpoise::KeyValueObject.last.blank?
      end

      def keys(key_name_or_search_string)
        if key_name_or_search_string.include?('*')
          return Porpoise::KeyValueObject.where(['key LIKE ?', key_name_or_search_string.gsub('%', '*')]).pluck(:key)
        else
          return Porpoise::KeyValueObject.where(key: key_name_or_search_string).pluck(:key)
        end
      end
    end
  end
end
