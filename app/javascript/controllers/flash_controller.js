// app/javascript/controllers/flash_controller.js
import { Controller } from "@hotwired/stimulus"
import { showNotification } from "utils/modal"

export default class extends Controller {
  static values = { notice: String, alert: String }
  
  connect() {
    if (this.hasNoticeValue && this.noticeValue) {
      showNotification(this.noticeValue, "success")
    }
    if (this.hasAlertValue && this.alertValue) {
      showNotification(this.alertValue, "error")
    }
  }
}