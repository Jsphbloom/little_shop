class Invoice < ApplicationRecord
  belongs_to :coupon, optional: true
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items

  validate :single_coupon_per_invoice, on: :create

  def self.filter_by_status(status)
    where("status = '#{status}'")
  end

  def single_coupon_per_invoice
    if coupon.present? && coupon_id != nil && Invoice.where.not(id: self.id).where(coupon_id: coupon_id).exists?
      errors.add(:coupon_id, "An invoice may only have ONE coupon.")
    end
  end
end

