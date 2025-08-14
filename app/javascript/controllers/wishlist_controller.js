// app/javascript/controllers/wishlist_controller.js
import { Controller } from "@hotwired/stimulus"
import { getCSRFToken } from "utils/csrf"
import { showNotification } from "utils/modal"

export default class extends Controller {
  static targets = ["button", "icon"]
  static values = { 
    propertyId: Number,
    wishlistId: Number,
    isWishlisted: Boolean 
  }

  connect() {
    this.isWishlistedValue = this.isWishlistedValue === true || this.isWishlistedValue === 'true'
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
          'X-CSRF-Token': getCSRFToken(),
        },
        credentials: 'include',
        body: JSON.stringify({
          property_id: this.propertyIdValue
        })
      })

      const data = await response.json()

      if (response.ok) {
        this.wishlistIdValue = data.id
        this.isWishlistedValue = true
        this.updateButtonState()
        showNotification(data.message || '찜 목록에 추가되었습니다', 'success')
      } else {
        showNotification(data.error || '오류가 발생했습니다', 'error')
      }
    } catch (error) {
      console.error('Add to wishlist error:', error)
      showNotification('네트워크 오류가 발생했습니다', 'error')
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
          'X-CSRF-Token': getCSRFToken(),
        },
        credentials: 'include'
      })

      const data = await response.json()

      if (response.ok) {
        this.wishlistIdValue = null
        this.isWishlistedValue = false
        this.updateButtonState()
        showNotification(data.message || '찜 목록에서 제거되었습니다', 'success')
      } else {
        showNotification(data.error || '오류가 발생했습니다', 'error')
      }
    } catch (error) {
      console.error('Remove from wishlist error:', error)
      showNotification('네트워크 오류가 발생했습니다', 'error')
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
}