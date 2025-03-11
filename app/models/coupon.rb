class Coupon < ApplicationRecord
  belongs_to :merchant
  has_one :invoice
  validates :name, :code, :discount_type, :discount_value, presence: true
  validates :code, presence: true, uniqueness: true
  validate :active_coupon_limit, on: :create
  validate :unique_name, on: :create
  # validate :single_coupon_per_invoice, on: :create


  def self.active_true
    where(active: true)
  end

  def self.active_false
    where(active: false)
  end

  def self.build(coupon_params)
    invoice = Invoice.find_by(merchant_id: coupon_params[:merchant_id])

    return nil unless invoice

    create(coupon_params.merge(invoice_id: invoice.id))
  end
end

private

def active_coupon_limit
  return unless merchant
  if active && merchant.coupons.where(active: true).count > 5
    errors.add(:base, "A merchant can only have up to 5 active coupons.")
  end
end

def unique_name
  return unless merchant
  if merchant.coupons.where(code: code).exists?
    errors.add(:name, "must be unique within a merchant's coupons.")
  end
end

# def single_coupon_per_invoice
#   return unless invoice_id.present?

#   if Invoice.exists?(invoice_id)
#     errors.add(:invoice_id, "An invoice may only have ONE coupon.") if Invoice.find(invoice_id).coupon_id.present?
#   end
# end
