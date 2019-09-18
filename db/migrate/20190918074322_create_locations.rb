class CreateLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :location, :primary_key => :location_id do |t|
      t.string      :name, null: false
      t.string      :code, uniq: true
      t.bigint      :location_type_id, null: false
      t.float       :latitude
      t.float       :longitude
      t.integer     :location_parent
      t.datetime    :date_created, null: false
      t.boolean     :retired, null: false, default: 0
      t.datetime    :retire_date

      t.timestamps
    end
    add_index :location, :name
    add_index :location, :code
    add_index :location, :location_type_id
    add_foreign_key :location, :location_type, 
    column: :location_type_id, primary_key: :location_type_id
  end

  def down
    drop_table :location 
  end

end
