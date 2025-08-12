class Review < ApplicationRecord
  belongs_to :user
  belongs_to :property

  validates :content, presence: true
  validates :cleanliness_rating, :accuracy_rating, :checkin_rating, :communication_rating,
            :location_rating, :value_rating,
            numericality: { only_integer: true, in: 1..5 }

  before_save :set_final_rating

  private

  def set_final_rating
    ratings = [
      cleanliness_rating,
      accuracy_rating,
      checkin_rating,
      communication_rating,
      location_rating,
      value_rating
    ]
    self.final_rating = (ratings.compact.sum.to_f / ratings.compact.size).round(1)
  end
end
