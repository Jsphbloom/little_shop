class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount
end
