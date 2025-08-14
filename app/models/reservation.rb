class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :property

  validates :checkin_date, presence: true
  validates :checkout_date, presence: true

  scope :upcoming_reservations, -> { where("checkin_date > ?", Date.today).order(:checkin_date) }

  scope :current_reservations, -> {
    where("checkin_date <= ? AND checkout_date >= ?", Date.today, Date.today)
      .order(:checkout_date)
  }

  scope :past_reservations, -> { where("checkout_date < ?", Date.today).order(checkout_date: :desc) }
end
