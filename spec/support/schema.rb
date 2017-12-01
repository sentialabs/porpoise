ActiveRecord::Schema.define do
  self.verbose = false
  
  create_table :key_value_objects, :force => true, :id => false do |t|
    t.string :key, null: false
    t.string :data_type, null: false, limit: 10
    t.text :value, limit: 65000000, null: false
    t.datetime :expiration_date
  end

  add_index :key_value_objects, :key, unique: true, name: 'indexA'
  add_index :key_value_objects, [:key, :expiration_date], name: 'indexB'
  add_index :key_value_objects, :data_type, name: 'indexD'
  add_index :key_value_objects, :expiration_date, name: 'indexE'
end
  