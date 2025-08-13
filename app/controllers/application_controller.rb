class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # CSRF 보호 활성화 (API에서도 필요)
  protect_from_forgery with: :exception

  # API 요청에서 CSRF 토큰을 헤더로 받을 수 있도록 설정
  protect_from_forgery with: :exception, unless: -> { request.format.json? && verified_request_via_header? }

  private

  def verified_request_via_header?
    request.headers["X-CSRF-Token"] == form_authenticity_token ||
    request.headers["HTTP_X_CSRF_TOKEN"] == form_authenticity_token
  end
end
