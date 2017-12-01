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

  DEADLOCK_RETRY_COUNT = 20

  serialize :value

  if ActiveRecord::VERSION::MAJOR == 3
    attr_accessible :key, :value, :data_type, :expiration_date
  end

  after_initialize :check_data_type
  before_validation :set_data_type

  validates_inclusion_of :data_type, in: %w(String Hash Array)

  scope :not_expired, -> { where(['(expiration_date IS NOT NULL AND expiration_date > ?) OR expiration_date IS NULL', Time.now]) }

  def self.retry_lock_error(retries = 20, &block)
    begin
      yield
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /Deadlock found when trying to get lock/ and (retries.nil? || retries > 0)
        retry_lock_error(retries ? retries - 1 : nil, &block)
      else
        raise e
      end
    end
  end

  def expired?
    !self.expiration_date.nil? && self.expiration_date < Time.now
  end
  
  def save
    super
  rescue ActiveRecord::RecordNotUnique
    # catch race conditions
    o = Porpoise::KeyValueObject.not_expired.where(key: self.key).first
    o.value = self.value
    o.expiration_date = self.expiration_date
    o.save
  end

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
