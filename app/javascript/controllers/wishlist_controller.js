// app/javascript/controllers/wishlist_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "icon"]
  static values = { 
    propertyId: Number,
    wishlistId: Number,
    isWishlisted: Boolean 
  }

  connect() {
    this.updateButtonState()
  }

  async toggle() {
    const isLoggedIn = document.body.getAttribute('data-logged-in') === 'true'
    if (this.isWishlistedValue) {
      await this.removeFromWishlist()
    } else {
      await this.addToWishlist()
    }
  }

  async addToWishlist() {
    try {
      const response = await fetch('/api/wishlists', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(), // CSRF 토큰 추가
        },
        credentials: 'include', // 세션 쿠키 포함
        body: JSON.stringify({
          property_id: this.propertyIdValue
        })
      })

      const data = await response.json()

      if (response.ok) {
        this.wishlistIdValue = data.id
        this.isWishlistedValue = true
        this.updateButtonState()
        this.showNotification(data.message || '찜 목록에 추가되었습니다', 'success')
      } else {
        this.showNotification(data.error || '오류가 발생했습니다', 'error')
      }
    } catch (error) {
      console.error('Add to wishlist error:', error)
      this.showNotification('네트워크 오류가 발생했습니다', 'error')
    }
  }

  async removeFromWishlist() {
    if (!this.wishlistIdValue) {
      console.error('Wishlist ID is missing')
      return
    }

    try {
      const response = await fetch(`/api/wishlists/${this.wishlistIdValue}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(), // CSRF 토큰 추가
        },
        credentials: 'include' // 세션 쿠키 포함
      })

      const data = await response.json()

      if (response.ok) {
        this.wishlistIdValue = null
        this.isWishlistedValue = false
        this.updateButtonState()
        this.showNotification(data.message || '찜 목록에서 제거되었습니다', 'success')
      } else {
        this.showNotification(data.error || '오류가 발생했습니다', 'error')
      }
    } catch (error) {
      console.error('Remove from wishlist error:', error)
      this.showNotification('네트워크 오류가 발생했습니다', 'error')
    }
  }

  updateButtonState() {

    const svgElement = this.element

    if (this.isWishlistedValue) {
      // 찜한 상태
      svgElement.setAttribute('data-status', 'true')
      }
    else {
      // 찜하지 않은 상태  
      svgElement.setAttribute('data-status', 'false')
    }
  }

  getCSRFToken() {
    // meta 태그에서 CSRF 토큰 가져오기
    const token = document.querySelector('meta[name="csrf-token"]')
    if (token) {
      return token.getAttribute('content')
    }

    // 전역 변수에서 가져오기 (로그인 후 저장된 경우)
    if (window.csrfToken) {
      return window.csrfToken
    }

    // Rails의 기본 방식으로 가져오기
    const railsUjs = document.querySelector('meta[name="csrf-token"]')
    if (railsUjs) {
      return railsUjs.content
    }

    console.error('CSRF token not found')
    return null
  }

  showNotification(message, type = 'info') {
    // 간단한 알림 표시 (실제 프로젝트에서는 토스트 라이브러리 사용 권장)
    if (type === 'success') {
      console.log('✅', message)
    } else if (type === 'error') {
      console.error('❌', message)
    } else {
      console.info('ℹ️', message)
    }

    // 실제 알림 UI 구현 예시 (선택사항)
    this.createToast(message, type)
  }

  createToast(message, type) {
    // 기존 토스트 제거
    const existingToast = document.querySelector('.custom-toast')
    if (existingToast) {
      existingToast.remove()
    }

    // 새 토스트 생성
    const toast = document.createElement('div')
    toast.className = `custom-toast alert alert-${type === 'error' ? 'danger' : type === 'success' ? 'success' : 'info'}`
    toast.style.cssText = `
      position: fixed;
      top: 20px;
      right: 20px;
      z-index: 9999;
      min-width: 300px;
      animation: slideIn 0.3s ease-out;
    `
    toast.textContent = message

    // CSS 애니메이션
    const style = document.createElement('style')
    style.textContent = `
      @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
      }
    `
    if (!document.querySelector('style[data-toast-animation]')) {
      style.setAttribute('data-toast-animation', 'true')
      document.head.appendChild(style)
    }

    document.body.appendChild(toast)

    // 3초 후 자동 제거
    setTimeout(() => {
      if (toast.parentNode) {
        toast.style.animation = 'slideIn 0.3s ease-out reverse'
        setTimeout(() => toast.remove(), 300)
      }
    }, 3000)
  }
}