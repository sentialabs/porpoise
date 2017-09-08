class PorpoiseCreateKeyValueObjects < ActiveRecord::Migration
  def up
    Porpoise::KeyValueObject.connection.create_table :key_value_objects, id: false do |t|
      t.string :key, null: false
      t.string :data_type, null: false, limit: 10
      t.text :value, limit: 65000000, null: false
      t.datetime :expiration_date
    end

    Porpoise::KeyValueObject.connection.add_index :key_value_objects, :key, unique: true
    Porpoise::KeyValueObject.connection.add_index :key_value_objects, [:key, :data_type]
    Porpoise::KeyValueObject.connection.add_index :key_value_objects, :key, name: 'key_fulltext_idx', type: :fulltext
    Porpoise::KeyValueObject.connection.add_index :key_value_objects, :data_type
    Porpoise::KeyValueObject.connection.add_index :key_value_objects, :expiration_date
  end

  def down
    Porpoise::KeyValueObject.connection.drop_table :key_value_objects
  end
end
