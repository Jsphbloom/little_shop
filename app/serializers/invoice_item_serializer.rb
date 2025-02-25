class InvoiceItemSerializer
  include JSONAPI::Serializer
  attributes :quantity, :unit_price
  belongs_to :invoice
  belongs_to :item
end
