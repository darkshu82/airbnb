/** app/javascript/services/wishlistService.js
 * Wishlist 관련 API 호출 및 상태 관리 서비스
 * - fetchWishlist: 서버에서 현재 사용자의 찜 목록 조회
 * - addWishlist: 특정 property를 찜 목록에 추가
 * - removeWishlist: 특정 찜 제거
 */
import { getCSRFToken } from "utils/csrf"

// 에러 메시지 상수화
const ERROR_MESSAGES = {
  NETWORK_ERROR: '네트워크 연결을 확인해주세요',
  API_ERROR: 'API 호출에 실패했습니다',
  TIMEOUT_ERROR: '요청 시간이 초과되었습니다',
  UNKNOWN_ERROR: '알 수 없는 오류가 발생했습니다'
}

const request = async (url, method = 'GET', body = null, useCsrf = false, timeout = 8000) => {
  const headers = { 'Content-Type': 'application/json' }
  if (useCsrf) headers['X-CSRF-Token'] = getCSRFToken()

  // AbortController로 타임아웃 구현
  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), timeout)

  try {
    const res = await fetch(url, {
      method,
      headers,
      credentials: 'include',
      body: body ? JSON.stringify(body) : null,
      signal: controller.signal
    })

    clearTimeout(timeoutId)

    const data = await res.json()
    
    if (!res.ok) {
      const errorMessage = data.error || `${ERROR_MESSAGES.API_ERROR} (${res.status})`
      throw new Error(errorMessage)
    }
    
    return data
    
  } catch (error) {
    clearTimeout(timeoutId)
    
    // 에러 타입별 메시지 처리
    if (error.name === 'AbortError') {
      console.error(`[WishlistService] ${method} ${url} timeout`)
      throw new Error(ERROR_MESSAGES.TIMEOUT_ERROR)
    } else if (error.name === 'TypeError' && error.message.includes('fetch')) {
      console.error(`[WishlistService] ${method} ${url} network error:`, error)
      throw new Error(ERROR_MESSAGES.NETWORK_ERROR)
    } else {
      console.error(`[WishlistService] ${method} ${url} failed:`, error)
      throw new Error(error.message || ERROR_MESSAGES.UNKNOWN_ERROR)
    }
  }
}

export const wishlistService = {
  async fetchWishlist() {
    const data = await request(
      '/api/wishlists?' + new URLSearchParams({ _: Date.now() }),
      'GET',
      null,
      false,
      5000 // 5초 타임아웃
    )
    return new Map(data.map(item => [item.property_id.toString(), item.id]))
  },

  async addWishlist(propertyId) {
    return await request(
      '/api/wishlists', 
      'POST', 
      { property_id: propertyId }, 
      true,
      8000 // 8초 타임아웃
    )
  },

  async removeWishlist(wishlistId) {
    return await request(
      `/api/wishlists/${wishlistId}`, 
      'DELETE', 
      null, 
      true,
      8000 // 8초 타임아웃
    )
  }
}