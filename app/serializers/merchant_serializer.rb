class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :coupons_count, :invoice_coupon_count
  attribute :item_count, if: proc { |merchant| merchant[:item_count] }
end
