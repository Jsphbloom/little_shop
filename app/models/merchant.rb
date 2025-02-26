class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  # Assumes an invoice belongs_to both a merchant and a customer.
  # Adding a through association to get unique customers for this merchant.
  has_many :customers, -> { distinct }, through: :invoices
  #has_many will return an array of objects, so we can call .distinct on it to get unique customers.
  #through is used to specify the association that we are traversing to get to the customers.
  #invoices is the association that we are traversing to get to the customers.
end
