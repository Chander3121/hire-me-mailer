class HrMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper
  default from: ENV.fetch("USER_MAIL", "hireme.chanderprakash@gmail.com")

  def send_resume(email:, subject:, body:, resume_path:, resume_filename:)
    attachments[resume_filename] = File.binread(resume_path)

    mail(to: email, subject: subject) do |format|
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
