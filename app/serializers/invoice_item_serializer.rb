class InvoiceItemSerializer
  include JSONAPI::Serializer
  attributes :item_id, :invoice_id, :quantity, :unit_price
end
