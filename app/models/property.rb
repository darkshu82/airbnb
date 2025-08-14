class Property < ApplicationRecord
  validates :name, presence: :true
  validates :headline, presence: :true
  validates :description, presence: :true
  validates :address_1, presence: :true
  validates :city, presence: :true
  validates :state, presence: :true
  validates :country, presence: :true
  monetize :price_cents, allow_nil: true
  has_many_attached :images
  has_many :reviews, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :wishlisted_users, through: :wishlists, source: :user
  has_many :reservations, dependent: :destroy
  has_many :reserved_users, through: :reservations, source: :user

  def set_average_final_rating
    avg = reviews.average(:final_rating)&.round(1) || 0.0
    update_column(:average_final_rating, avg)
  end

  def available_dates
    # 현재 진행 중이거나 미래 예약
    next_reservation = reservations.upcoming_reservations.order(:checkin_date).first
    current_reservation = reservations.current_reservations.first

    # start_date / end_date 계산
    if current_reservation.nil? && next_reservation.nil?
      start_date = Date.tomorrow
      end_date = Date.tomorrow + 30
    elsif current_reservation.nil?
      start_date = Date.tomorrow
      end_date = next_reservation.checkin_date
    elsif next_reservation.nil?
      start_date = current_reservation.checkout_date
      end_date = Date.tomorrow + 30
    else
      start_date = current_reservation.checkout_date
      end_date = next_reservation.checkin_date
    end

    # 문자열 포맷 반환
    "#{start_date.strftime('%d %b')} - #{end_date.strftime('%d %b')}"
  end

  def available_date_ranges
    ranges = []
    today = Date.today
    reservations_sorted = reservations.upcoming_reservations.order(:checkin_date)
    start_date = today + 1

    reservations_sorted.each do |res|
      if start_date < res.checkin_date
        ranges << (start_date...res.checkin_date)
      end
      start_date = res.checkout_date + 1
    end

    ranges << (start_date..(today + 30)) if start_date <= (today + 30)
    ranges
  end
end
