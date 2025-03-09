FactoryBot.define do
  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :invoice_item do
    quantity { Faker::Number.decimal_part(digits: 2) }
    invoice
    item
    unit_price { item.unit_price }
  end

  factory :invoice do
    status { ["shipped", "returned", "packaged"].sample }
    customer
    merchant
  end

  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Commerce.material }
    unit_price { Faker::Commerce.price }
    merchant
  end

  factory :merchant do
    name { Faker::Commerce.vendor }
  end

  factory :transaction do
    credit_card_number { Faker::Stripe.valid_card }
    credit_card_expiration_date { "#{Faker::Stripe.month}/#{Faker::Stripe.year[2..3]}" }
    invoice
    result { invoice.status }
  end

  factory :coupon do
    name { Faker::Commerce.color }
    code { Faker::Commerce.promotion_code(digits: 2) }
    discount_type { ["Percent", "Dollar off"].sample }
    discount_value { Faker::Number.within(range: 1..100) }
    merchant
    active { [true, false].sample }
  end
end
