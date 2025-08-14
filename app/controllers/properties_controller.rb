# app/controllers/properties_controller.rb
def index
  @properties = Property.order(created_at: :desc).page(params[:page])

  @wishlist_map = {}
  if current_user
    @wishlist_map = current_user.wishlists
      .where(property_id: @properties.map(&:id))
      .pluck(:property_id, :id)
      .to_h
  end
end
