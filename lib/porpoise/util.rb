module Porpoise
  module Util
    class << self
      def ping
        return Porpoise::KeyValueObject.count >= 0
      end
    end
  end
end
