// app/javascript/controllers/wishlist_sync_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lastSync: Number }

  constructor() {
    super(...arguments)
    
    // 핵심 이벤트만 유지 (8개 -> 3개로 축소)
    this.boundHandlePageChange = this.handlePageChange.bind(this)
    this.boundHandleVisibilityChange = this.handleVisibilityChange.bind(this)
    this.boundHandleWishlistChange = this.handleWishlistChange.bind(this)

    // 통합 이벤트 맵 (대폭 축소)
    this.eventMap = [
      // 페이지 변화 관련 (turbo 이벤트들을 하나로 통합)
      [document, 'turbo:load', this.boundHandlePageChange],
      // 사용자 상호작용
      [document, 'visibilitychange', this.boundHandleVisibilityChange],
      // 위시리스트 변경 (추가/제거)
      [document, 'wishlist:wishlistAdded', this.boundHandleWishlistChange],
      [document, 'wishlist:wishlistRemoved', this.boundHandleWishlistChange]
    ]

    this.processedElements = new WeakSet()
    this.syncTimeout = null
  }

  connect() {
    // 초기 동기화 지연 시간 증가 (500ms -> 1000ms)
    setTimeout(() => this.syncWishlistStates('initial'), 1000)
    this.eventMap.forEach(([target, event, handler]) => 
      target.addEventListener(event, handler)
    )
  }

  disconnect() {
    this.eventMap.forEach(([target, event, handler]) => 
      target.removeEventListener(event, handler)
    )
    this.processedElements = new WeakSet()
    if (this.syncTimeout) {
      clearTimeout(this.syncTimeout)
    }
  }

  // 통합 이벤트 핸들러들
  handlePageChange() {
    this.scheduleSync('page-change', 500) // 페이지 변경 시 500ms 대기
  }

  handleVisibilityChange() {
    if (!document.hidden) {
      this.scheduleSync('visibility-change', 800) // 탭 포커스 시 800ms 대기
    }
  }

  handleWishlistChange() {
    this.scheduleSync('wishlist-change', 100) // 위시리스트 변경 시 즉시 동기화
  }

  // 개선된 스케줄링 (쓰로틀링 강화)
  scheduleSync(reason = 'unknown', delay = 1000) {
    const now = Date.now()
    
    // 쓰로틀링 시간 증가 (300ms -> 1000ms)
    if (this.lastSyncValue && now - this.lastSyncValue < 1000) {
      console.log(`⏱️ 동기화 스킵 (쓰로틀링): ${reason}`)
      return
    }

    // 기존 타이머가 있으면 취소
    if (this.syncTimeout) {
      clearTimeout(this.syncTimeout)
    }

    console.log(`📅 동기화 예약: ${reason} (${delay}ms 후)`)
    this.syncTimeout = setTimeout(() => {
      this.syncWishlistStates(reason)
      this.syncTimeout = null
    }, delay)
  }

  // 헬퍼 메소드들 (변경 없음)
  getWishlistElements() {
    return Array.from(
      document.querySelectorAll('[data-controller*="wishlist"]:not([data-controller*="wishlist-sync"])')
    )
  }

  getControllerForElement(element) {
    return this.application.getControllerForElementAndIdentifier(element, 'wishlist')
  }

  getCurrentWishlistId(controller) {
    return (controller.wishlistIdValue === null || isNaN(controller.wishlistIdValue)) 
      ? null : controller.wishlistIdValue
  }

  needsUpdate(controller, isWishlisted, wishlistId) {
    return controller.isWishlistedValue !== isWishlisted || 
           this.getCurrentWishlistId(controller) !== wishlistId
  }

  // 실제 동기화 로직 (에러 처리 강화)
  async syncWishlistStates(reason = 'unknown') {
    try {
      if (document.body.getAttribute('data-logged-in') !== 'true') {
        console.log('🚫 비로그인 사용자 - 동기화 스킵')
        return
      }

      const wishlistElements = this.getWishlistElements()
      if (!wishlistElements.length) {
        console.log('📭 위시리스트 요소 없음 - 동기화 스킵')
        return
      }

      console.log(`🔄 위시리스트 동기화 시작: ${reason}`)
      this.lastSyncValue = Date.now()

      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 5000) // 5초 타임아웃

      try {
        const response = await fetch('/api/wishlists?' + new URLSearchParams({ 
          _: Date.now() 
        }), {
          method: 'GET',
          headers: { 
            'Content-Type': 'application/json', 
            'Accept': 'application/json',
            'Cache-Control': 'no-cache'
          },
          credentials: 'include',
          signal: controller.signal
        })

        clearTimeout(timeoutId)

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }

        const wishlists = await response.json()
        const wishlistedMap = new Map(
          wishlists.map(w => [w.property_id.toString(), w.id])
        )

        let updatedCount = 0
        wishlistElements.forEach(element => {
          if (this.processedElements.has(element)) return

          const controller = this.getControllerForElement(element)
          if (!controller) return

          const propertyId = element.getAttribute('data-wishlist-property-id-value')
          if (!propertyId) return

          const isWishlisted = wishlistedMap.has(propertyId)
          const wishlistId = isWishlisted ? wishlistedMap.get(propertyId) : null

          if (this.needsUpdate(controller, isWishlisted, wishlistId)) {
            controller.updateFromSync(isWishlisted, wishlistId)
            updatedCount++
          }

          this.processedElements.add(element)
        })

        console.log(`✅ 동기화 완료: ${updatedCount}개 요소 업데이트`)

      } catch (fetchError) {
        clearTimeout(timeoutId)
        throw fetchError
      }

    } catch (error) {
      if (error.name === 'AbortError') {
        console.error('⌛ 위시리스트 동기화 타임아웃')
      } else if (error.message.includes('fetch')) {
        console.error('🌐 네트워크 오류:', error.message)
      } else {
        console.error('❌ 위시리스트 동기화 실패:', error.message)
      }
    }
  }
}