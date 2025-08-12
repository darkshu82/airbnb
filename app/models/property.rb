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
  has_many :reviews

  def set_average_final_rating
    avg = reviews.average(:final_rating)&.round(1) || 0.0
    update_column(:average_final_rating, avg)
  end
end
