class ApplicationsMailerPreview < ActionMailer::Preview

	#  These methods allow you to view your email template in the browser
  #  http://localhost:3000/rails/mailers/applications_mailer/application_received

  def application_received
    ApplicationsMailer.application_received(Application.first)
  end

  def application_success
    ApplicationsMailer.application_success(Application.first)
  end

	def application_rejected
    ApplicationsMailer.application_rejected(Application.first)
  end
end