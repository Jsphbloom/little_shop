class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  def self.format_merchants(merchants)
    merchant_data = merchants.map do |merchant|
      {
        id: merchant.id,
        type: "merchant",
        attributes: {
          name: merchant.name
        }
      }
    end

    return  { data: merchant_data }
  end
end
