# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# merchant1 = Merchant.create!(name: "Super Deals Store")
# merchant2 = Merchant.create!(name: "Budget Goods")

# merchant1.coupons.create!([
#   { name: "Half Off", code: "HALF50", discount: "50%", status: "active" },
#   { name: "BOGO", code: "BOGOFREE", discount: "Buy One Get One", status: "active" }
# ])

# merchant2.coupons.create!([
#   { name: "10 Bucks Off", code: "SAVE10", discount: "$10 Off", status: "inactive" },
#   { name: "Spring Sale", code: "SPRING15", discount: "15% Off", status: "active" }
# ])

cmd = "pg_restore --verbose --clean --no-acl --no-owner -h localhost -U $(whoami) -d little_shop_development db/data/little_shop_development.pgdump"
puts "Loading PostgreSQL Data dump into local database with command:"
puts cmd
system(cmd)
