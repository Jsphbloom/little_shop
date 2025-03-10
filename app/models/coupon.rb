class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  validates :name, :code, :discount_type, :discount_value, presence: true
  validates :code, presence: true, uniqueness: true
  validate :active_coupon_limit, on: :create

  def self.active_true
    where(active: true)
  end

  def self.active_false
    where(active: false)
  end
end

private

def active_coupon_limit
  if active && merchant.coupons.where(active: true).count >= 5
    errors.add(:base, "A merchant can only have up to 5 active coupons.")
  end
end
