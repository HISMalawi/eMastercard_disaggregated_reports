class CreateCaseTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :case_type, :primary_key => :case_type_id do |t|
      t.string      :name, null: false
      t.boolean  :voided, null: false, default: 0
      t.string   :void_reason

      t.timestamps
    end
  end

  def sown
    drop_table :case_type
  end
end
