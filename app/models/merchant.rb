class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy
  # The customers association leverages invoices to return unique customers.
  has_many :customers, -> { distinct }, through: :invoices
  #explanation of the above line:
  #The customers association leverages invoices to return unique customers.
  #The through: :invoices option tells Rails to use the invoices association to find the customers.
  #The -> { distinct } lambda tells Rails to return only unique customers.
end
