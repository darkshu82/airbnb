require 'faker'

user = User.find_or_create_by!(email: 'test1@gmail.com') do |u|
  u.password = '123456'
end

ratings = %i[cleanliness_rating accuracy_rating checkin_rating communication_rating location_rating value_rating]

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
    price: Money.from_amount(rand(40.0..200.0).round(2), "USD")
  )

  # 이미지 첨부
  image_files = (1..2).map do |j|
    path = Rails.root.join("app/assets/images/property/property_#{i+1}_#{j}.jpg")
    path if File.exist?(path)
  end.compact

  if image_files.any?
    property.images.attach(
      image_files.map do |file_path|
        { io: File.open(file_path, 'rb'), filename: File.basename(file_path) }
      end
    )
  else
    puts "이미지 파일이 없습니다: property #{i+1}"
  end

  # 리뷰 생성
  rand(5..10).times do
    attrs = { content: Faker::Lorem.paragraph(sentence_count: 10), property: property, user: user }
    ratings.each { |key| attrs[key] = rand(1..5) }
    Review.create!(attrs)
  end
end
