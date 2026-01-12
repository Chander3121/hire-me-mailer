import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "editorPanel", "name", "content", "form", "method"]

  connect() {
    this._bindListListener()
    this._bindFormSave()
  }

  disconnect() {
    if (this.listTarget && this.listTarget._tmplListener) {
      this.listTarget.removeEventListener('click', this.listTarget._tmplListener)
      delete this.listTarget._tmplListener
    }
    if (this.formTarget && this.formTarget._saveListener) {
      this.formTarget.removeEventListener('submit', this.formTarget._saveListener)
      delete this.formTarget._saveListener
    }
  }

  _bindListListener() {
    if (!this.hasListTarget) return
    const list = this.listTarget
    list._tmplListener = (e) => {
      const btn = e.target.closest('.template-item')
      if (!btn) return
      const id = btn.dataset.id
      this.loadTemplate(id, btn)
    }
    list.addEventListener('click', list._tmplListener)
  }

  _bindFormSave() {
    if (!this.hasFormTarget) return
    const form = this.formTarget
    form._saveListener = (e) => {
      if (window.tinymce && tinymce.get(this.contentTarget.id)) {
        tinymce.get(this.contentTarget.id).save()
      }
    }
    form.addEventListener('submit', form._saveListener)
  }

  loadTemplate(id, btn) {
    if (this.hasEditorPanelTarget) this.editorPanelTarget.classList.remove('hidden')

    // initialize tinyMCE when available
    this.ensureTinyMCEInit(() => {
      fetch(`${this._templatesPath()}/${id}`, { credentials: 'same-origin' })
        .then(r => { if (!r.ok) throw new Error('not found'); return r.text() })
        .then(text => {
          if (window.tinymce && tinymce.get(this.contentTarget.id)) {
            tinymce.get(this.contentTarget.id).setContent(text)
          } else {
            this.contentTarget.value = text
          }
        }).catch(() => {})
    })

    if (btn) this.nameTarget.value = btn.textContent.trim()
    // set form action and method to update
    this.formTarget.action = `${this._templatesPath()}/${id}`
    this.methodTarget.value = 'patch'
  }

  ensureTinyMCEInit(done) {
    if (window.tinymce) {
      if (!tinymce.get(this.contentTarget.id)) {
        tinymce.init({ selector: `#${this.contentTarget.id}`, height: 500, plugins: 'lists link image code help wordcount', toolbar: 'formatselect | bold italic | bullist numlist | link | code', menubar: false })
        setTimeout(() => { if (done) done() }, 50)
      } else {
        if (done) done()
      }
    } else {
      setTimeout(() => { this.ensureTinyMCEInit(done) }, 100)
    }
  }

  _templatesPath() {
    // Using absolute path expected by routes: /emails/templates
    return '/emails/templates'
  }
}
