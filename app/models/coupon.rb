class Coupon < ApplicationRecord
  belongs_to :merchant
  has_one :invoice
  validates :name, :code, :discount_type, :discount_value, presence: true
  validates :code, presence: true, uniqueness: true
  validate :active_coupon_limit, on: [:create, :update]
  validate :unique_name, on: :create

  def self.active_true
    where(active: true)
  end

  def self.active_false
    where(active: false)
  end

  def self.build(coupon_params)
    invoice_id = coupon_params[:invoice_id]
    invoice = Invoice.find_by(id: invoice_id)
    return nil unless invoice

    coupon = create(coupon_params.merge(invoice_id: invoice.id))

    invoice.update(coupon_id: coupon.id)
    coupon
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
