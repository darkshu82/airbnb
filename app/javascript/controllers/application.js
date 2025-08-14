// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"
import Swal from "sweetalert2"

const application = Application.start()
application.debug = false
window.Stimulus   = application

export { application }