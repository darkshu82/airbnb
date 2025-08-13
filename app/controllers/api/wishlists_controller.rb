# app/controllers/api/wishlists_controller.rb
module Api
  class WishlistsController < Api::BaseController
    before_action :validate_property_exists, only: [ :create ]

    def index
      Rails.logger.info "=== INDEX ACTION ==="
      Rails.logger.info "Current user: #{current_user&.id}"
      Rails.logger.info "User signed in: #{user_signed_in?}"

      # 세션 기반 인증 확인
      unless user_signed_in?
        Rails.logger.warn "User not signed in via session"
        render json: { error: "로그인이 필요합니다" }, status: :unauthorized and return
      end

      wishlists = current_user.wishlists.includes(:property)
      Rails.logger.info "Wishlists count: #{wishlists.count}"

      render json: (wishlists.map do |wishlist|
        property = wishlist.property

        {
          id: wishlist.id,
          property_id: wishlist.property_id,
          property: {
            id: property.id,
            name: property.name,
            description: property.description,
            price: property.price_cents,
            address_1: property.address_1,
            address_2: property.address_2,
            city: property.city,
            state: property.state,
            country: property.country
          }
        }
      end), status: :ok
    end

    def create
      Rails.logger.info "=== CREATE ACTION ==="
      Rails.logger.info "Current user: #{current_user&.id}"
      Rails.logger.info "User signed in: #{user_signed_in?}"
      Rails.logger.info "Params: #{params.inspect}"
      Rails.logger.info "Session: #{session.inspect}"

      # 세션 기반 인증 확인
      unless user_signed_in?
        Rails.logger.warn "User not signed in via session"
        render json: { error: "로그인이 필요합니다" }, status: :unauthorized and return
      end

      if current_user.wishlists.exists?(property_id: wishlist_params[:property_id])
        Rails.logger.info "Already exists in wishlist"
        render json: { error: "이미 찜한 목록입니다" }, status: :unprocessable_entity and return
      end

      wishlist = current_user.wishlists.new(wishlist_params)
      Rails.logger.info "New wishlist: #{wishlist.inspect}"

      if wishlist.save
        Rails.logger.info "Wishlist saved successfully: #{wishlist.id}"
        render json: {
          id: wishlist.id,
          property_id: wishlist.property_id,
          message: "찜 목록에 추가되었습니다"
        }, status: :created
      else
        Rails.logger.error "Wishlist save failed: #{wishlist.errors.full_messages}"
        render json: { errors: wishlist.errors.full_messages }, status: :unprocessable_entity
      end

    rescue StandardError => e
      Rails.logger.error "Error in create: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "서버 오류가 발생했습니다" }, status: :internal_server_error
    end

    def destroy
      Rails.logger.info "=== DESTROY ACTION ==="
      Rails.logger.info "Current user: #{current_user&.id}"
      Rails.logger.info "User signed in: #{user_signed_in?}"
      Rails.logger.info "Wishlist ID: #{params[:id]}"

      # 세션 기반 인증 확인
      unless user_signed_in?
        Rails.logger.warn "User not signed in via session"
        render json: { error: "로그인이 필요합니다" }, status: :unauthorized and return
      end

      wishlist = current_user.wishlists.find(params[:id])

      if wishlist.destroy
        Rails.logger.info "Wishlist destroyed successfully"
        render json: { message: "찜 목록에서 제거되었습니다" }, status: :ok
      else
        Rails.logger.error "Wishlist destroy failed: #{wishlist.errors.full_messages}"
        render json: { errors: wishlist.errors.full_messages }, status: :unprocessable_entity
      end

    rescue ActiveRecord::RecordNotFound
      Rails.logger.error "Wishlist not found: #{params[:id]}"
      render json: { error: "찜 목록을 찾을 수 없습니다" }, status: :not_found
    rescue StandardError => e
      Rails.logger.error "Error in destroy: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "서버 오류가 발생했습니다" }, status: :internal_server_error
    end

    private

    def wishlist_params
      params.permit(:property_id)
    end

    def validate_property_exists
      property_id = params[:property_id]
      Rails.logger.info "Validating property_id: #{property_id}"

      unless Property.exists?(id: property_id)
        Rails.logger.error "Property not found: #{property_id}"
        render json: { error: "해당 부동산을 찾을 수 없습니다" }, status: :not_found and return
      end
    end

    # 추가: 인증 실패 시 JSON 응답 처리
    def authenticate_user!
      unless user_signed_in?
        Rails.logger.warn "Authentication failed - no valid session"
        render json: {
          error: "로그인이 필요합니다",
          redirect: new_user_session_path
        }, status: :unauthorized and return
      end
    end
  end
end
