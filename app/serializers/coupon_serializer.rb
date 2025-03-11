class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :discount_value, :active, :merchant_id, :invoice_id, :times_used
end
