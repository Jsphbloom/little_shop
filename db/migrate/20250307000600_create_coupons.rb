class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    if table_exists?(:merchants)
      create_table :coupons do |t|
        t.string :name, null: false
        t.string :code, null: false
        t.string :discount_type, null: false
        t.float :discount_value, null: false
        t.references :merchant, foreign_key: true, null: false
        t.references :invoice, foreign_key: true, null: false
        t.boolean :active, default: true
        t.timestamps
      end
      add_index :coupons, :code, unique: true
    else
      raise ActiveRecord::MigrationError, "Merchants table must exist before creating coupons."
    end
  end
end
