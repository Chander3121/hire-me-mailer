import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "templateSelect", "resume", "resumeDisplay", "resumeError", "form"]

  connect() {
    this.ensureTinyMCEInit()
    this._bindTemplateLoader()
    this._bindResumeUpload()
    this._bindFormSave()
  }

  ensureTinyMCEInit() {
    const init = () => {
      if (window.tinymce) {
        if (tinymce.get(this.bodyTarget.id)) tinymce.remove(`#${this.bodyTarget.id}`)
        tinymce.init({ selector: `#${this.bodyTarget.id}`, plugins: 'lists link image code help wordcount', toolbar: 'formatselect | bold italic underline strikethrough | bullist numlist | link image | code | help', menubar: false, height: 400, statusbar: true, branding: false, promotion: false, skin: 'oxide', content_css: 'default' })
      } else {
        setTimeout(init, 150)
      }
    }
    if (this.hasBodyTarget) init()
  }

  _bindTemplateLoader() {
    if (!this.hasTemplateSelectTarget) return
    this.templateSelectTarget.addEventListener('change', (e) => {
      const id = e.target.value
      if (!id) return
      fetch(`/emails/templates/${encodeURIComponent(id)}`, { credentials: 'same-origin' })
        .then(resp => { if (!resp.ok) throw new Error('Template not found'); return resp.text() })
        .then(text => {
          if (window.tinymce && tinymce.get(this.bodyTarget.id)) {
            tinymce.get(this.bodyTarget.id).setContent(text)
          } else if (this.hasBodyTarget) {
            this.bodyTarget.value = text
          }
        }).catch(() => {})
    })
  }

  _bindResumeUpload() {
    if (!this.hasResumeTarget) return
    const fileInput = this.resumeTarget
    const display = this.hasResumeDisplayTarget ? this.resumeDisplayTarget : null
    const errorDisplay = this.hasResumeErrorTarget ? this.resumeErrorTarget : null
    const MAX_SIZE = 10 * 1024 * 1024
    const ALLOWED_TYPES = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']

    fileInput.addEventListener('change', () => {
      if (errorDisplay) { errorDisplay.classList.add('hidden'); errorDisplay.innerHTML = '' }
      const file = fileInput.files && fileInput.files[0]
      if (file) {
        if (!ALLOWED_TYPES.includes(file.type) && !file.name.match(/\.(pdf|doc|docx)$/i)) {
          if (errorDisplay) { errorDisplay.innerHTML = '❌ Only PDF, DOC, or DOCX files allowed'; errorDisplay.classList.remove('hidden') }
          fileInput.value = ''
          if (display) display.innerHTML = ''
          return
        }
        if (file.size > MAX_SIZE) {
          if (errorDisplay) { errorDisplay.innerHTML = '❌ File size must be less than 10MB (your file: ' + (file.size / (1024 * 1024)).toFixed(2) + 'MB)'; errorDisplay.classList.remove('hidden') }
          fileInput.value = ''
          if (display) display.innerHTML = ''
          return
        }
        if (display) display.innerHTML = '✓ New file selected: <strong>' + file.name + '</strong>'
      } else {
        if (display) display.innerHTML = ''
      }
    })
  }

  _bindFormSave() {
    if (!this.hasFormTarget) return
    this.formTarget.addEventListener('submit', () => {
      if (window.tinymce && tinymce.get(this.bodyTarget.id)) tinymce.get(this.bodyTarget.id).save()
    })
  }
}
