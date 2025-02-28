class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
  attribute :count, if: Proc.new { |merchant, params| 
    params[:count].present? && params[:count] == "true"
}
end
