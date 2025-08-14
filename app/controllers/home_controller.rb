# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @properties = Property.all
    if current_user
      @wishlist_map = current_user.wishlists.pluck(:property_id, :id).to_h
    else
      @wishlist_map = {}
    end
  end
end
