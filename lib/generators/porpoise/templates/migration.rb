class PorpoiseCreateKeyValueObjects < ActiveRecord::Migration
  def change
    KeyValueObject.connection.create_table :key_value_objects, id: false do |t|
      t.string :key, null: false
      t.string :data_type, null: false, limit: 10
      t.text :value, limit: 65000000, null: false
      t.datetime :expiration_date
    end

    KeyValueObject.connection.add_index :key_value_objects, :key, unique: true
    KeyValueObject.connection.add_index :key_value_objects, :key, name: 'key_fulltext_idx', type: :fulltext
    KeyValueObject.connection.add_index :key_value_objects, :data_type
    KeyValueObject.connection.add_index :key_value_objects, :expiration_date
  end
end
