class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price
  has_many :invoice_items
  belongs_to :merchant
end
