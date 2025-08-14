class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :wishlists, dependent: :destroy
  has_many :wishlisted_properties, through: :wishlists, source: :property

  has_many :reservations, dependent: :destroy
  has_many :reserved_properties, through: :reservations, source: :property

  def add_to_wishlist(property)
    wishlists.find_or_create_by(property: property)
  end

  def remove_from_wishlist(property)
    wishlists.find_by(property: property)&.destroy
  end
end
