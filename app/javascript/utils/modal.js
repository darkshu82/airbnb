// app/javascript/utils/modal.js
import Swal from "sweetalert2"

export function showNotification(message, type = "info") {
  Swal.fire({
    toast: true,
    position: "top-end",
    showConfirmButton: false,
    timer: 2000,
    timerProgressBar: true,
    icon: type,
    title: message,
  })
}

export function showConfirm(title, text = "") {
  return Swal.fire({
    title: title,
    text: text,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: '확인',
    cancelButtonText: '취소'
  })
}

export function showAlert(title, text = "", icon = 'info') {
  return Swal.fire({
    title: title,
    text: text,
    icon: icon,
    confirmButtonText: '확인'
  })
}