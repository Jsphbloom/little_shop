class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices, optional: true

  validates :code, presence: true, uniqueness: true
end
