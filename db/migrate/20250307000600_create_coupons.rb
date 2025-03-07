class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.string :discount_type
      t.float :discount_value
      t.references :merchant, foreign_key: true
      t.timestamps
    end
    change_table :invoices do |t|
      t.references :coupon, foreign_key: true
    end
  end
end
