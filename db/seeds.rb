require 'faker'
Faker::Config.locale = 'en'

puts "Seeding users..."
users = 5.times.map do |i|
  User.create!(
    email: "test#{i+1}@gmail.com",
    password: "123123",
    password_confirmation: "123123"
  )
end

ratings = %i[cleanliness_rating accuracy_rating checkin_rating communication_rating location_rating value_rating]

puts "Seeding properties..."
properties = 12.times.map do |i|
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
    property.update!(image_url: Rails.application.routes.url_helpers.rails_blob_path(
      property.images.first, only_path: true
    ))
  else
    puts "이미지 파일이 없습니다: property #{i+1}"
  end

  # 리뷰 생성
  rand(5..10).times do
    attrs = { content: Faker::Lorem.paragraph(sentence_count: 10), property: property, user: users.sample }
    ratings.each { |key| attrs[key] = rand(1..5) }
    Review.create!(attrs)
  end

  property
end

# 예약 생성 (과거·현재·미래 섞어서)
puts "Seeding reservations..."
users.each do |user|
  properties.sample(6).each_with_index do |property, idx|
    case idx % 3
    when 0
      # 과거 예약
      checkin_date = Date.today - rand(10..20).days
      checkout_date = checkin_date + rand(1..5).days
    when 1
      # 현재 예약
      checkin_date = Date.today - rand(1..2).days
      checkout_date = Date.today + rand(1..3).days
    when 2
      # 미래 예약
      checkin_date = Date.today + rand(1..10).days
      checkout_date = checkin_date + rand(1..5).days
    end

    Reservation.create!(
      user: user,
      property: property,
      checkin_date: checkin_date,
      checkout_date: checkout_date
    )
  end
end

puts "Seeding completed!"
