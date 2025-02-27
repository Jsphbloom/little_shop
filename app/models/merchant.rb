class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  # The customers association leverages invoices to return unique customers.
  has_many :customers, -> { distinct }, through: :invoices
end
