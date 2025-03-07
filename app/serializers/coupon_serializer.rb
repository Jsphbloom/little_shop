class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :discount_value, :active
end
