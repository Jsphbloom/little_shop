class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name, :item_count
end
