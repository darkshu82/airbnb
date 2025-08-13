import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    setTimeout(() => {
      // 페이드 아웃 애니메이션 후 제거 (선택사항)
      this.element.style.transition = "opacity 0.5s ease";
      this.element.style.opacity = 0;

      setTimeout(() => {
        this.element.remove();
      }, 500);
    }, 3000); // 3초 후 사라짐
  }
}
