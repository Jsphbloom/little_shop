class AddCouponsCountAndInvoiceCouponCountToMerchants < ActiveRecord::Migration[7.1]
  def change
    add_column :merchants, :coupons_count, :integer, default: 0, null: false
    add_column :merchants, :invoice_coupon_count, :integer, default: 0, null: false
  end
end
