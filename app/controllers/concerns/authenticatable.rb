# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern

  # included 블록 안에서 before_action을 조건별로 걸 수 있음
  # include Authenticatable
  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!(redirect_if_html: true)
    unless user_signed_in?
      Rails.logger.warn "Authentication failed - no valid session"

      respond_to do |format|
        format.json do
          render json: {
            error: "로그인이 필요합니다",
            redirect: new_user_session_path
          }, status: :unauthorized
        end
        format.html do
          redirect_to new_user_session_path, alert: "로그인이 필요합니다" if redirect_if_html
        end
      end
    end
  end
end
