class TransactionSerializer
  include JSONAPI::Serializer
  attributes :invoice_id, :credit_card_number, :credit_card_expiration_date, :result
end
