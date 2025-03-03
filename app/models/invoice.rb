class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items

  def self.filter_by_status(status)
    where("status = '#{status}'")
  end
end
