// app/javascript/controllers/wishlist_controller.js
import { Controller } from "@hotwired/stimulus"
import { showNotification } from "utils/modal"
import { wishlistService } from "services/wishlistService"

const MESSAGES = {
  LOGIN_REQUIRED: '로그인이 필요합니다',
  INVALID_STATE: '찜 상태가 올바르지 않습니다',
  DEFAULT_ERROR: '오류가 발생했습니다',
  ADD_SUCCESS: '찜 목록에 추가되었습니다',
  REMOVE_SUCCESS: '찜 목록에서 제거되었습니다'
}

export default class extends Controller {
  static targets = ["button", "icon"]
  static values = { 
    propertyId: Number,
    wishlistId: Number,
    isWishlisted: Boolean 
  }

  connect() {
    this.normalizeValues()
    this.updateButtonState()
    this.setupAccessibility() // 접근성 설정 추가
  }

  // 접근성 설정 메소드 추가
  setupAccessibility() {
    const button = this.element
    
    // role과 tabindex 설정
    if (!button.hasAttribute('role')) {
      button.setAttribute('role', 'button')
    }
    
    if (!button.hasAttribute('tabindex')) {
      button.setAttribute('tabindex', '0')
    }

    // 키보드 이벤트 리스너 추가
    if (!button.hasAttribute('data-keyboard-listener')) {
      button.addEventListener('keydown', this.handleKeydown.bind(this))
      button.setAttribute('data-keyboard-listener', 'true')
    }

    this.updateAriaLabel()
  }

  // 키보드 접근성 핸들러
  handleKeydown(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      this.toggle(event)
    }
  }

  // ARIA 라벨 업데이트
  updateAriaLabel() {
    const isWishlisted = Boolean(this.isWishlistedValue)
    const label = isWishlisted ? '찜 목록에서 제거' : '찜 목록에 추가'
    this.element.setAttribute('aria-label', label)
    
    // 상태 표시를 위한 aria-pressed 추가
    this.element.setAttribute('aria-pressed', isWishlisted.toString())
  }

  normalizeValues() {
    this.isWishlistedValue = this.isWishlistedValue === true || this.isWishlistedValue === 'true'
    this.wishlistIdValue = (!this.wishlistIdValue || isNaN(this.wishlistIdValue) || this.wishlistIdValue === 0) ? null : this.wishlistIdValue
  }

  async toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (document.body.getAttribute('data-logged-in') !== 'true') {
      showNotification(MESSAGES.LOGIN_REQUIRED, 'error')
      return
    }

    // 로딩 상태 표시 (접근성)
    this.element.setAttribute('aria-busy', 'true')

    try {
      if (this.isWishlistedValue) {
        await this.removeFromWishlist()
      } else {
        await this.addToWishlist()
      }
    } catch (error) {
      showNotification(error.message || MESSAGES.DEFAULT_ERROR, 'error')
    } finally {
      // 로딩 상태 해제
      this.element.setAttribute('aria-busy', 'false')
    }
  }

  async addToWishlist() {
    const data = await wishlistService.addWishlist(this.propertyIdValue)
    this.wishlistIdValue = data.id
    this.isWishlistedValue = true
    this.updateButtonState()
    this.updateAriaLabel() // 접근성 라벨 업데이트
    showNotification(data.message || MESSAGES.ADD_SUCCESS, 'success')
    this.dispatch('wishlistAdded', { 
      detail: { propertyId: this.propertyIdValue, wishlistId: data.id } 
    })
  }

  async removeFromWishlist() {
    if (!this.wishlistIdValue) {
      showNotification(MESSAGES.INVALID_STATE, 'error')
      return
    }

    const removedPropertyId = this.propertyIdValue
    const removedWishlistId = this.wishlistIdValue

    const data = await wishlistService.removeWishlist(this.wishlistIdValue)
    this.wishlistIdValue = null
    this.isWishlistedValue = false
    this.updateButtonState()
    this.updateAriaLabel() // 접근성 라벨 업데이트
    showNotification(data.message || MESSAGES.REMOVE_SUCCESS, 'success')
    this.dispatch('wishlistRemoved', { 
      detail: { propertyId: removedPropertyId, wishlistId: removedWishlistId } 
    })
  }

  updateButtonState() {
    const isWishlisted = Boolean(this.isWishlistedValue)
    this.element.setAttribute('data-status', isWishlisted.toString())
  }

  updateFromSync(isWishlisted, wishlistId) {
    this.isWishlistedValue = isWishlisted
    this.wishlistIdValue = wishlistId
    this.updateButtonState()
    this.updateAriaLabel() // 동기화 시에도 접근성 라벨 업데이트
  }
}
