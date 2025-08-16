# app/controllers/concerns/wishlist_mapable.rb
module WishlistMapable
  extend ActiveSupport::Concern

  # 1. 유저의 찜 목록 배열 반환
  def user_wishlists(user)
    return [] unless user
    user.wishlists.includes(:property)
  end

  # 2. 찜 맵 { property_id => wishlist_id } 반환
  def build_wishlist_map(user, properties)
    return {} unless user
    user.wishlists
        .where(property_id: properties.map(&:id))
        .pluck(:property_id, :id)
        .to_h
  end
end
