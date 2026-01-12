import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const toast = this.element.querySelector('#flash_toast')
    if (!toast) return
    toast.style.opacity = 0
    toast.style.transition = 'opacity 200ms ease-in-out, transform 200ms ease'
    toast.style.transform = 'translateY(8px)'
    setTimeout(() => { toast.style.opacity = 1; toast.style.transform = 'translateY(0)' }, 10)
    setTimeout(() => { toast.style.opacity = 0; toast.style.transform = 'translateY(8px)' }, 3500)
    setTimeout(() => { this.element.innerHTML = '' }, 4200)
  }
}
