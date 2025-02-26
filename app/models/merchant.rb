class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :invoices, dependent: :destroy
  has_many :items, dependent: :destroy

  def self.sort_by_asc
    Merchant.all.order(created_at: :asc)
  end

  def self.sort_by_desc
    Merchant.all.order(created_at: :desc)
  end
end
