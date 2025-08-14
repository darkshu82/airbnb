// app/javascript/utils/csrf.js
export function getCSRFToken() {
  const tokenMeta = document.querySelector('meta[name="csrf-token"]')
  if (tokenMeta) return tokenMeta.getAttribute('content')
  if (window.csrfToken) return window.csrfToken

  console.error('CSRF token not found')
  return null
}
