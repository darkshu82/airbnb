// app/javascript/controllers/swiper_controller.js
import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"

export default class extends Controller {
  connect() {
    this.swiper = new Swiper(this.element, {
      loop: true,
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },
    })
  }

  disconnect() {
    if (this.swiper) {
      this.swiper.destroy()
    }
  }
}