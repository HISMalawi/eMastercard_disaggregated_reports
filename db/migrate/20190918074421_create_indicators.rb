class CreateIndicators < ActiveRecord::Migration[5.2]
  def change
    create_table :indicator, :primary_key => :indicator_id do |t|
      t.bigint   :indicator_type_id, null: false
      t.bigint   :case_id, null: false
      t.integer  :value, null: false

      t.timestamps
    end
    add_index :indicator, :indicator_type_id
    add_index :indicator, :case_id
    add_foreign_key :indicator, :indicator_type, column: :indicator_type_id, primary_key: :indicator_type_id
    add_foreign_key :indicator, :cases, column: :case_id, primary_key: :case_id
    execute "ALTER TABLE `indicator` CHANGE `created_at` `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
    execute "ALTER TABLE `indicator` CHANGE `updated_at` `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
  end

  def down
    drop_table :indicator
  end
end
