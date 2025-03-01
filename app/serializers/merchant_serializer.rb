class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  attribute :count, if: proc { |merchant, params|
    params[:count].present? && params[:count] == "true"
  }
end
