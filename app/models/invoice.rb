class Invoice < ApplicationRecord
  belongs_to :customer, :merchant
  has_many :transactions, :invoice_items
end