module Porpoise
  module Util
    class << self
      def ping
        return !Porpoise::KeyValueObject.last.blank?
      end
    end
  end
end
