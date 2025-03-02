class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  has_many :invoice_items
  belongs_to :merchant

  def self.sort_by_price
    order(unit_price: :asc)
  end
end
