# app/controllers/home_controller.rb
class HomeController < ApplicationController
  include WishlistMapable

  def index
    @properties = Property.order(created_at: :desc)

    # 개별 배열
    @wishlists = user_wishlists(current_user)

    # 뷰에서 바로 쓸 수 있는 맵
    @wishlist_map = build_wishlist_map(current_user, @properties)
  end
end
