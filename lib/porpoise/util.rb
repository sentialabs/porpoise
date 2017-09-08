module Porpoise
  module Util
    class << self
      def ping
        return !KeyValueObject.last.blank?
      end

      def keys(key_name_or_search_string)
        if key_name_or_search_string.include?('*')
          return KeyValueObject.where(['key LIKE ?', key_name_or_search_string.gsub('%', '*')]).pluck(:key)
        else
          return KeyValueObject.where(key: key_name_or_search_string).pluck(:key)
        end
      end
    end
  end
end
