class HrMailer < ApplicationMailer
  default from: "hireme.chanderprakash@gmail.com"

  def send_resume(email, subject, body, resume)
    filename =
      if resume.respond_to?(:original_filename)
        resume.original_filename
      else
        File.basename(resume.path)
      end

    attachments[filename] = resume.read

    mail(to: email, subject: subject) do |format|
      format.html { render html: body.html_safe }
    end
  end
end
