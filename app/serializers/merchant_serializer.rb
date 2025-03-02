class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  attribute :item_count, if: proc { |merchant| merchant[:item_count] }
end
