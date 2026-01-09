"""
TinyMCE initializer kept for documentation only.

We initialize TinyMCE directly from the Cloud CDN in the view when an API
key is present (see app/views/emails/new.html.erb). The previous code
attempted to call `TinyMCE.configure`, which is not provided in this app
and caused the initializer to raise at boot. Keep this file as a safe
reference. If you later add a server-side TinyMCE library that exposes a
`configure` method, restore configuration here.
"""

Rails.logger.info "TinyMCE initializer skipped — editor is initialized from CDN in views when API key is present."
