class HrMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  def send_resume(email:, subject:, body:, resume_path:, resume_filename:, setting: nil)
    attachments[resume_filename] = File.binread(resume_path)

    mail_from = ENV.fetch("USER_MAIL", "hireme.chanderprakash@gmail.com")

    delivery_options = {}

    if setting.present? && setting.gmail_app_password.present? && setting.email.present?
      mail_from = setting.email
      delivery_options = {
        address: "smtp.gmail.com",
        port: 587,
        domain: "smtp.gmail.com",
        user_name: setting.email,
        password: setting.gmail_app_password,
        authentication: :plain,
        enable_starttls_auto: true
      }
    end

    mail(
      from: mail_from,
      to: email,
      subject: subject,
      delivery_method_options: delivery_options
    ) do |format|
      format.text { render plain: body }
      format.html do
        render html: sanitize(
          body,
          tags: %w[p br strong b em i u ul ol li a],
          attributes: %w[href]
        ).html_safe
      end
    end
  end
end
