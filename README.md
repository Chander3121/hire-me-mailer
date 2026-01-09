# Job Mailer – Bulk Resume Sender

A modern, full-featured Rails application for sending resumes to multiple HR professionals. Features a beautiful glassmorphic UI, rich text editor with TinyMCE, secure file handling, background job processing, and comprehensive email logging.

## Features

✨ **Modern UI**
- Glassmorphic design with Tailwind CSS
- Gradient backgrounds and smooth animations
- Responsive layout for mobile and desktop
- Beautiful email logs dashboard with status badges

📄 **Resume Management**
- File upload with drag & drop support
- Support for PDF, DOC, DOCX formats (max 10MB)
- Client-side and server-side validation
- Filename display and change detection
- Edit forms with resume preservation

✉️ **Email Composition**
- Compose bulk emails to multiple recipients (comma or newline separated)
- Rich text editor powered by TinyMCE Cloud
- Subject line and HTML body support
- Form preview before sending
- Edit existing drafts anytime

🚀 **Background Processing**
- Sidekiq-based job queue for reliable sending
- Staggered email delivery (1-minute delays between sends)
- Real-time job monitoring via Sidekiq UI
- Email status tracking (pending, sent, failed)

📊 **Email Logging**
- Complete audit trail of all sent emails
- Recipient, subject, and delivery status
- Sent timestamp tracking
- Filterable and sortable logs

🔒 **Security**
- Session data cached (not stored in cookies)
- Secure file validation and temporary storage
- CSRF protection and secure headers
- Content Security Policy compliance

## Quick Start

### Prerequisites
- Ruby (see `.ruby-version`)
- SQLite (default) or PostgreSQL
- Bundler

### Installation

1. **Clone and install dependencies:**
   ```bash
   bundle install
   ```

2. **Setup database:**
   ```bash
   rails db:create db:migrate db:seed
   ```

3. **Start Sidekiq worker** (in a separate terminal):
   ```bash
   bundle exec sidekiq
   ```

4. **Start Rails server:**
   ```bash
   rails server
   ```

5. **Open in browser:**
   ```
   http://localhost:3000
   ```

## Configuration

### Email (SMTP)

Configure SMTP settings via environment variables or Rails credentials:

```bash
# .env (development)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_DOMAIN=gmail.com
SMTP_AUTH_METHOD=login
SMTP_ENABLE_STARTTLS_AUTO=true
```

Or use Rails credentials:
```bash
rails credentials:edit
```

Add:
```yaml
smtp:
  address: smtp.gmail.com
  port: 587
  username: your-email@gmail.com
  password: your-app-password
  domain: gmail.com
```

### TinyMCE Rich Editor (Optional)

To enable the rich text editor for email composition:

1. **Get API key** from [TinyMCE Cloud](https://www.tiny.cloud)

2. **Set environment variable:**
   ```bash
   export TINYMCE_API_KEY=your_api_key_here
   ```

   Or via Rails credentials:
   ```bash
   rails credentials:edit
   ```
   Add:
   ```yaml
   tinymce:
     api_key: your_api_key_here
   ```

Without an API key, the app uses a plain textarea as fallback.

See [docs/TINYMCE.md](docs/TINYMCE.md) for detailed setup instructions.

## How It Works

### User Flow

1. **Compose** – User enters recipient emails, subject, and body (with optional rich editing)
2. **Upload Resume** – Select PDF/DOC/DOCX file (max 10MB)
3. **Preview** – Review message and recipient list before sending
4. **Confirm & Send** – Submit to queue background jobs
5. **Monitor** – View email logs and job status

### Architecture

**Frontend:**
- [app/views/emails/new.html.erb](app/views/emails/new.html.erb) – Form with validation and TinyMCE
- [app/views/emails/confirm.html.erb](app/views/emails/confirm.html.erb) – Preview page
- [app/views/email_logs/index.html.erb](app/views/email_logs/index.html.erb) – Email history and status

**Backend:**
- [app/controllers/emails_controller.rb](app/controllers/emails_controller.rb) – Form handling, validation, caching
- [app/jobs/send_resume_job.rb](app/jobs/send_resume_job.rb) – Background job that sends emails
- [app/mailers/hr_mailer.rb](app/mailers/hr_mailer.rb) – Email composition and delivery
- [app/models/email_log.rb](app/models/email_log.rb) – Tracks sent emails

**Storage:**
- Session data: Rails.cache (expires in 30 minutes)
- Resume files: `tmp/` directory (temporary, cleaned up after send)
- Email logs: Database (persistent)

### Data Flow

1. **Create (POST /emails):**
   - Validates email list, subject, resume file
   - Stores payload in Rails.cache with 30-min TTL
   - Stores token in session
   - Redirects to confirm page

2. **Confirm (GET /emails/confirm):**
   - Retrieves payload from cache using session token
   - Displays preview to user

3. **Send Emails (POST /emails/send_emails):**
   - Creates EmailLog record for each recipient
   - Queues SendResumeJob with 1-minute staggered delays
   - Cleans up cache and session

4. **SendResumeJob:**
   - Loads resume file from tmp/
   - Calls HrMailer.send_resume
   - Updates EmailLog status

5. **Edit (GET /emails/edit):**
   - Loads cached payload
   - Pre-fills form with existing data
   - Preserves resume file if no new file selected

## File Structure

```
app/
  controllers/
    emails_controller.rb          # Main form and send logic
  jobs/
    send_resume_job.rb            # Background email sender
  mailers/
    hr_mailer.rb                  # Email composition
  models/
    email_log.rb                  # Email tracking
  views/
    emails/
      new.html.erb                # Form with upload & TinyMCE
      confirm.html.erb            # Preview before send
    email_logs/
      index.html.erb              # Logs with status badges
    layouts/
      application.html.erb        # Main layout with Tailwind
config/
  routes.rb                       # URL routing
  initializers/
    tinymce.rb                    # TinyMCE config
docs/
  TINYMCE.md                      # TinyMCE setup guide
```

## Monitoring & Debugging

### Sidekiq Admin UI
Access job queue and worker status at:
```
http://localhost:3000/sidekiq
```

### Email Logs
View sent/failed/pending emails at:
```
http://localhost:3000/email_logs
```

### Logs
Check Rails logs for errors:
```bash
tail -f log/development.log
```

## Production Deployment

### Important Notes
- ⚠️ **File Storage:** `tmp/` is not persistent in production. Use AWS S3 or ActiveStorage for reliable resume storage.
- 🔐 **Credentials:** Use environment variables or Rails encrypted credentials, never hardcode secrets.
- 📦 **Sidekiq:** Run as a managed background process (systemd, Docker, or platform service).
- 💾 **Database:** Use PostgreSQL in production; SQLite is development-only.
- 🚀 **Cache:** Configure Redis for Rails.cache instead of default file/memory store.

### Example Docker Setup
The repo includes a `Dockerfile` for containerized deployment. Build and run:
```bash
docker build -t job-mailer .
docker run -p 3000:3000 \
  -e SMTP_ADDRESS=... \
  -e SMTP_USERNAME=... \
  -e TINYMCE_API_KEY=... \
  job-mailer
```

## Testing

Run the full test suite:
```bash
rails test
```

Run specific test:
```bash
rails test test/controllers/emails_controller_test.rb
```

## Troubleshooting

### Emails Not Sending
1. Check Sidekiq UI at `/sidekiq` for failed jobs
2. Review Rails logs: `tail -f log/development.log`
3. Verify SMTP credentials and firewall/port access
4. Check email logs at `/email_logs` for status

### Resume Upload Failing
- Ensure file is PDF, DOC, or DOCX
- Check file size is under 10MB
- Verify `tmp/` directory exists and is writable

### TinyMCE Not Loading
- Verify API key is set (env var or credentials)
- Check browser console for CDN errors
- App falls back to plain textarea if key is missing

### Session/Caching Issues
- Clear Rails cache: `rails runner 'Rails.cache.clear'`
- Restart server: `rails server`
- Check `config/cache.yml` for cache store configuration

## Contributing

Found a bug or have a feature request? Open an issue or submit a pull request!

## License

MIT License – see LICENSE file for details.

## Support

For questions or issues, check the troubleshooting section above or review the code comments in the key files listed above.

