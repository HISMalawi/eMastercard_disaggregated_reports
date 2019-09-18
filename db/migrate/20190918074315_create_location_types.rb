class CreateLocationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :location_type, :primary_key => :location_type_id do |t|
      t.string   :name, null: false
      t.boolean  :voided, null: false, default: 0
      t.string   :void_reason
                                         
      t.timestamps                       
    end
  end

  def down
    drop_table  :location_type
  end

end
