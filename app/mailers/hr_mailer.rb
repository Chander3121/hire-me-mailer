class HrMailer < ApplicationMailer
  default from: "hireme.chanderprakash@gmail.com"

  def send_resume(*args, **kwargs)
    # support both positional and keyword args for flexibility in tests
    if kwargs.any?
      email = kwargs[:recipient] || kwargs[:email]
      subject = kwargs[:subject]
      body = kwargs[:body]
      resume = kwargs[:resume_path] || kwargs[:resume]
    else
      email, subject, body, resume = args
    end

    # If a path string was passed, open the file
    resume = File.open(resume) if resume.is_a?(String)

    filename = if resume.respond_to?(:original_filename)
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
