TinyMCE API key setup

You can provide the TinyMCE Cloud API key using either an environment variable or Rails encrypted credentials.

1) Environment variable (recommended for containers / CI)

- Set `TINYMCE_API_KEY` in your environment before starting the app:

```bash
export TINYMCE_API_KEY=your-tinymce-cloud-key
# then start the app
bin/rails server
```

2) Rails credentials (encrypted)

- Open credentials editor:

```bash
EDITOR="nano" bin/rails credentials:edit
```

- Add the following YAML structure inside (example):

```yaml
tinymce:
  api_key: "your-tinymce-cloud-key"
```

- Save and exit. Rails will encrypt and store the credentials in `config/credentials.yml.enc`.

Notes
- The app looks for the key in `ENV['TINYMCE_API_KEY']` first, then falls back to `Rails.application.credentials.dig(:tinymce, :api_key)`.
- If the key is missing, the app will show a notice and fall back to a plain textarea.
- For production, prefer setting the environment variable in your hosting platform (Heroku, Render, Docker, etc.).

TinyMCE Cloud docs: https://www.tiny.cloud/docs/