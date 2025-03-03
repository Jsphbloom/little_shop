class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true
  has_many :invoice_items
  belongs_to :merchant

  def self.sort_by_price
    order(unit_price: :asc)
  end

  def self.search(params)
    if params[:name]
      Item.find_by("name ILIKE ?", "%#{params[:name]}%")
    elsif params[:min_price] && params[:max_price]
      Item.find_by("unit_price >= ? AND unit_price <= ?", params[:min_price], params[:max_price])
    elsif params[:min_price]
      Item.find_by("unit_price >= ?", params[:min_price])
    elsif params[:max_price]
      Item.find_by("unit_price <= ?", params[:max_price])
    end
  end
end
