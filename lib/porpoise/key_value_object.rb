class Porpoise::KeyValueObject < ActiveRecord::Base
  class Porpoise::TypeMismatch < StandardError
    def initialize(msg)
      super(msg)
    end
  end
  
  class Porpoise::KeyNotFound < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  self.primary_key = 'key'

  # :nocov:
  unless ENV['rack_env'] && ENV['rack_env'].eql?('test')
    config = YAML.load(File.read('config/database.yml'))
    establish_connection config["porpoise_#{Rails.env}"]
  end
  # :nocov:

  serialize :value

  attr_accessible :key, :value, :data_type, :expiration_date

  after_initialize :check_data_type
  before_validation :set_data_type

  validates_inclusion_of :data_type, in: %w(String Hash Array)

  private

  def check_data_type
    if !self.data_type.nil? && self.value.class.name != self.data_type
      raise Porpoise::TypeMismatch.new(
        "#{self.value.class.name} is not of type #{self.data_type}"
      )
    end
  end   

  def set_data_type
    self.data_type = self.value.class.name
  end
end
