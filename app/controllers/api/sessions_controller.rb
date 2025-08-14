# app/controllers/api/sessions_controller.rb
module Api
  class SessionsController < Api::BaseController
    include Authenticatable
    skip_before_action :authenticate_user!, only: [ :create ]
    respond_to :json

    def create
      user = User.find_by(email: sign_in_params[:email])

      if user&.valid_password?(sign_in_params[:password])
        # Devise의 기본 sign_in 메서드로 세션 생성
        sign_in(user)

        render json: {
          message: "로그인 성공",
          user: {
            id: user.id,
            email: user.email
          },
          csrf_token: form_authenticity_token
        }, status: :ok
      else
        render json: { error: "이메일 또는 비밀번호가 잘못되었습니다" }, status: :unauthorized
      end
    end

    def destroy
      if user_signed_in?
        sign_out(current_user)
        render json: { message: "로그아웃 되었습니다" }, status: :ok
      else
        render json: { error: "로그인되지 않은 상태입니다" }, status: :unauthorized
      end
    end

    private

    def sign_in_params
      params.require(:user).permit(:email, :password)
    end
  end
end
