class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  has_many :invoices
  has_many :items
end
