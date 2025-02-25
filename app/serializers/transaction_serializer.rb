class TransactionSerializer
  include JSONAPI::Serializer
  attributes :credit_card_number, :credit_card_expiration_date, :result
  belongs_to :invoice
end
