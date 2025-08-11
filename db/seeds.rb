require 'faker'

12.times do |i|
  property = Property.create!(
    name: Faker::Address.community,
    description: Faker::Lorem.sentence,
    headline: Faker::Marketing.buzzwords,
    address_1: Faker::Address.street_address,
    address_2: [ nil, Faker::Address.secondary_address ].sample,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    country: Faker::Address.country,
    # image_url: Faker::Avatar.image(slug: "house-#{i}", size: "400x400"),
    price: Money.from_amount(Faker::Commerce.price(range: 40.0..200.0, as_string: false).round(2), "USD"),
  )

  image_files = (1..2).map do |j|
    path = Rails.root.join("app", "assets", "images", "property", "property_#{i+1}_#{j}.jpg")
    File.exist?(path) ? path : nil
  end.compact

  if image_files.any?
    property.images.attach(
      image_files.map do |file_path|
        { io: File.open(file_path), filename: File.basename(file_path) }
      end
    )
  else
    puts "이미지 파일이 없습니다: property #{i+1}"
  end
end
