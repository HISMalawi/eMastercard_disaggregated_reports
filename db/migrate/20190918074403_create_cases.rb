class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases, :primary_key => :case_id  do |t|
      t.bigint    :case_type_id, null: false
      t.bigint    :timeline_id, null: false

      t.timestamps
    end
    add_index :cases, :case_type_id
    add_index :cases, :timeline_id
    add_foreign_key :cases, :case_type, 
    column: :case_type_id, primary_key: :case_type_id
    add_foreign_key :cases, :reporting_timeline, 
    column: :timeline_id, primary_key: :timeline_id
    execute "ALTER TABLE `cases` CHANGE `created_at` `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
    execute "ALTER TABLE `cases` CHANGE `updated_at` `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
  end

  def down
    drop_table  :cases
  end

end
