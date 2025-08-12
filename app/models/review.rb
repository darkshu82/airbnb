class Review < ApplicationRecord
  belongs_to :user
  belongs_to :property, counter_cache: true

  validates :content, presence: true
  validates :cleanliness_rating, :accuracy_rating, :checkin_rating, :communication_rating,
            :location_rating, :value_rating,
            numericality: { only_integer: true, in: 1..5 }

  before_save :set_final_rating
  after_save :update_property_average_rating
  after_destroy :update_property_average_rating

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

  private
  def update_property_average_rating
    property&.set_average_final_rating
  end
end
