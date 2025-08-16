# app/models/concerns/wishlist_messages.rb
module WishlistMessages
  extend self

  # I18n을 사용한 메시지 조회
  def get(key, options = {})
    I18n.t("wishlist.messages.#{key}", **options)
  rescue I18n::MissingTranslationData
    Rails.logger.warn "Missing translation for wishlist.messages.#{key}"
    I18n.t("wishlist.messages.unknown_error")
  end

  # 액션 메시지 조회
  def action(key, options = {})
    I18n.t("wishlist.actions.#{key}", **options)
  rescue I18n::MissingTranslationData
    Rails.logger.warn "Missing translation for wishlist.actions.#{key}"
    key.to_s.humanize
  end

  # 상태 메시지 조회
  def state(key, options = {})
    I18n.t("wishlist.states.#{key}", **options)
  rescue I18n::MissingTranslationData
    Rails.logger.warn "Missing translation for wishlist.states.#{key}"
    key.to_s.humanize
  end

  # 백업용 하드코딩된 메시지들 (I18n 실패 시)
  FALLBACK_MESSAGES = {
    already_wishlisted: "이미 찜한 목록입니다",
    not_found: "찜 목록을 찾을 수 없습니다",
    property_not_found: "해당 부동산을 찾을 수 없습니다",
    added_success: "찜 목록에 추가되었습니다",
    removed_success: "찜 목록에서 제거되었습니다",
    server_error: "서버 오류가 발생했습니다",
    unknown_error: "알 수 없는 오류가 발생했습니다"
  }.freeze

  def fallback(key)
    FALLBACK_MESSAGES[key] || FALLBACK_MESSAGES[:unknown_error]
  end
end
