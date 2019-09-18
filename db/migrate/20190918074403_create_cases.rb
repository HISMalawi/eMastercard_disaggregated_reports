class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases, :primary_key => :case_id  do |t|
      t.bigint     :case_type_id, null: false
      t.bigint     :location_id, null: false
      t.datetime   :case_reported_datetime, null: false

      t.timestamps
    end
    add_index :cases, :case_type_id
    add_index :cases, :location_id
    add_index :cases, :case_reported_datetime
    add_foreign_key :cases, :case_type, 
    column: :case_type_id, primary_key: :case_type_id
    add_foreign_key :cases, :location, 
    column: :location_id, primary_key: :location_id
  end

  def down
    drop_table  :cases
  end

end
