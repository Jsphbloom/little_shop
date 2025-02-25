class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price

  def self.format_items(items)
    item_data = items.map do |item|
      {
        id: item.id,
        type: "item",
        attributes: {
          name: item.name,
          description: item.description,
          unit_price: item.unit_price,
          merchant_id: item.merchant_id
        }
      }
    end

    return  { data: item_data }
  end
end
