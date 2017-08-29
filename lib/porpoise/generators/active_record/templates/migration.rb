class PorpoiseCreateKeyValueObjects < ActiveRecord::Migration
  def change
    create_table :key_value_objects, id: false do |t|
      t.string :key, null: false
      t.string :data_type, null: false, limit: 10
      t.text :value, limit: 65000000, null: false
      t.datetime :expiration_date
    end

    add_index :key_value_objects, :key, unique: true
    add_index :key_value_objects, :key, type: :fulltext
    add_index :key_value_objects, :data_type
    add_index :key_value_objects, :expiration_date
  end
end
