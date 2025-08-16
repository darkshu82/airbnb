# app/controllers/properties_controller.rb
class PropertiesController < ApplicationController
  include WishlistMapable
  def show
    @property = Property.find(params[:id])
    @wishlist = current_user.present? ? current_user.wishlists.find_by(property: @property) : nil
  end
end
