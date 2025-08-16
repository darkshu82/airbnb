# app/controllers/api/wishlists_controller.rb
module Api
  class WishlistsController < Api::BaseController
    include Authenticatable

    before_action :set_cache_headers, only: [ :index ]
    before_action :validate_property_exists, only: [ :create ]

    def index
      wishlists = current_user.wishlists.select(:id, :property_id, :created_at)
      render json: wishlists.map { |w| { id: w.id, property_id: w.property_id } }, status: :ok
    end

    def create
      if current_user.wishlists.exists?(property_id: wishlist_params[:property_id])
        return render json: { error: WishlistMessages.get(:already_wishlisted) },
                     status: :unprocessable_entity
      end

      wishlist = current_user.wishlists.new(wishlist_params)
      save_and_render(wishlist, WishlistMessages.get(:added_success))
    rescue StandardError => e
      log_and_render_error(e, "Wishlist create error")
    end

    def destroy
      wishlist = current_user.wishlists.find_by(id: params[:id])
      unless wishlist
        return render json: { error: WishlistMessages.get(:not_found) },
                     status: :not_found
      end

      property_id = wishlist.property_id
      if wishlist.destroy
        render json: {
          message: WishlistMessages.get(:removed_success),
          property_id: property_id,
          wishlist_id: params[:id].to_i
        }, status: :ok
      else
        render json: { errors: wishlist.errors.full_messages },
               status: :unprocessable_entity
      end
    rescue StandardError => e
      log_and_render_error(e, "Wishlist destroy error")
    end

    private

    def wishlist_params
      params.fetch(:wishlist, params).permit(:property_id)
    end

    def validate_property_exists
      return if Property.exists?(id: wishlist_params[:property_id])

      render json: { error: WishlistMessages.get(:property_not_found) },
             status: :not_found
      false
    end

    def set_cache_headers
      response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
      fresh_when(current_user.wishlists.maximum(:updated_at))
    end

    def save_and_render(record, message)
      if record.save
        render json: {
          id: record.id,
          property_id: record.property_id,
          message: message
        }, status: :created
      else
        render json: { errors: record.errors.full_messages },
               status: :unprocessable_entity
      end
    end

    def log_and_render_error(error, context = "")
      Rails.logger.error "#{context}: #{error.message}"
      render json: { error: WishlistMessages.get(:server_error) },
             status: :internal_server_error
    end
  end
end
