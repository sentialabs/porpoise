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

  config = YAML.load(File.read('config/database.yml'))
  establish_connection config["porpoise_#{Rails.env}"]

  serialize :value

  attr_accessible :key, :value, :data_type, :expiration_date

  before_validation :set_data_type, on: :create

  validates_inclusion_of :data_type, in: %w(String Hash Array)
  validate :validate_data_type, on: :update

  def initialize
    if @value.class.name != @data_type
      raise Porpoise::TypeMismatch.new("#{@value.class.name} is not of type #{@data_type}")
    end
  end

  private

  def validate_data_type
    self.errors.add(:data_type, "does not match the data type of the object (#{@value.class.name})")
  end

  def set_data_type
    @data_type = @value.class.name
  end
end
