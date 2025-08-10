import { Controller } from "@hotwired/stimulus"
import { enter, leave, toggle } from 'el-transition'

// Connects to data-controller="header"
export default class extends Controller {
  static targets = ['dropdown', 'openUserMenu']

  toggleDropdown() {
    toggle(this.dropdownTarget)

    const isExpanded = !this.dropdownTarget.classList.contains('hidden')
    this.openUserMenuTarget.setAttribute('aria-expanded', isExpanded)
  }

  close(event) {
    if (event.type === "click" && this.element.contains(event.target)) {
      return
    }
    this.closeDropdown()
  }

  closeDropdown() {
    leave(this.dropdownTarget)
    this.openUserMenuTarget.setAttribute('aria-expanded', 'false')
  }
}