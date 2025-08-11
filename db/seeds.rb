require 'faker'

20.times do |i|
  Property.create!(
    name: Faker::Address.community,
    description: Faker::Lorem.sentence,
    headline: Faker::Marketing.buzzwords,
    address_1: Faker::Address.street_address,
    address_2: [ nil, Faker::Address.secondary_address ].sample,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    country: Faker::Address.country,
    image_url: Faker::Avatar.image(slug: "house-#{i}", size: "400x400"),
    price: Money.from_amount(Faker::Commerce.price(range: 40.0..200.0, as_string: false).round(2), "USD"),
  )
end
