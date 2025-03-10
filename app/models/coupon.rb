class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices

  validates :code, presence: true, uniqueness: true

  def self.active_true
    where(active: true)
  end

  def self.active_false
    where(active: false)
  end
end
