class ChangeInvoiceIdOnCouponsToNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :coupons, :invoice_id, true
  end
end
