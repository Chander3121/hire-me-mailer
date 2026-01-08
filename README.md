# Job Mailer (Send Resume to HR)

Purpose
-------
A lightweight Rails app that helps you send a resume to multiple HR emails. You paste or upload a resume, compose a subject and HTML body (TinyMCE is integrated), preview the message, and schedule sends. Each send is enqueued as a background job and logged.

Quick start (development)
-------------------------
1. Install Ruby (see `.ruby-version` if present) and PostgreSQL/SQLite as preferred.
2. Install dependencies:

	bundle install

3. Setup the database:

	rails db:create db:migrate db:seed

4. Start Sidekiq in a separate terminal (jobs use Sidekiq):

	bundle exec sidekiq

5. Boot the app:

	rails server

Then open http://localhost:3000 and send a test.

How it works (overview)
-----------------------
- Frontend: `app/views/emails/new.html.erb` provides a form to enter HR emails, subject, HTML body (TinyMCE), and upload a resume.
- Preview: `emails#create` stores form data in session and renders a preview (`emails/preview.html.erb`).
- Scheduling: `emails#show` creates `EmailLog` records and enqueues `SendResumeJob` for each recipient.
- Background worker: `app/jobs/send_resume_job.rb` loads the resume file and calls `HrMailer.send_resume`.
- Mailer: `app/mailers/hr_mailer.rb` attaches the resume and sends HTML email.

Configuration (mail)
--------------------
Set SMTP environment variables in `.env` or your host (examples):

- `SMTP_ADDRESS` (smtp server)
- `SMTP_PORT` (587)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_DOMAIN`
- `SMTP_AUTH_METHOD` (e.g. `login`)
- `SMTP_ENABLE_STARTTLS_AUTO` (true/false)

The app uses Rails mailer configuration from `config/environments/*`. Update those if you need provider-specific options.

Queues and monitoring
---------------------
- Sidekiq is used for background processing. The Sidekiq UI is mounted at `/sidekiq`.
- Jobs update `EmailLog` status (`pending`, `sent`, `failed`). See `app/models/email_log.rb` and the `email_logs#index` view.

Security & production notes
---------------------------
- Do not store resumes in `tmp` for long in production—use persistent storage (S3 or ActiveStorage).
- Use environment vars (not checked-in files) for SMTP credentials.
- Run Sidekiq as a managed process in production and use a robust DB and file store.

Testing
-------
Run the Rails test suite:

  rails test

Troubleshooting
---------------
- If mails are not sending, check Sidekiq logs and Rails logs for exceptions.
- Verify SMTP settings and ports are reachable from your host.

Useful files
------------
- Mailer: [app/mailers/hr_mailer.rb](app/mailers/hr_mailer.rb#L1-L40)
- Job: [app/jobs/send_resume_job.rb](app/jobs/send_resume_job.rb#L1-L80)
- Controller: [app/controllers/emails_controller.rb](app/controllers/emails_controller.rb#L1-L120)
- Form: [app/views/emails/new.html.erb](app/views/emails/new.html.erb#L1-L80)
- Preview: [app/views/emails/preview.html.erb](app/views/emails/preview.html.erb#L1-L80)

If you'd like, I can add a sample `.env.example`, a small rake task to clean `tmp` resumes, or wire ActiveStorage instead of temporary files. Which would you prefer?
