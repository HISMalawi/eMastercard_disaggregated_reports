class CreateReportingTimelines < ActiveRecord::Migration[5.2]
  def change
    create_table :reporting_timeline, :primary_key => :timeline_id do |t|
      t.string      :report_name, null: false
      t.bigint      :location_id, null: false
      t.datetime    :report_datetime, null: false

      t.timestamps
    end
    add_index :reporting_timeline, :location_id
    add_index :reporting_timeline, :report_datetime
    execute "ALTER TABLE `reporting_timeline` CHANGE `created_at` `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
    execute "ALTER TABLE `reporting_timeline` CHANGE `updated_at` `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP"
  end

  def down
    drip_table  :reporting_timeline
  end
end
