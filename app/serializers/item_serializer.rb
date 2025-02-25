class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price

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
