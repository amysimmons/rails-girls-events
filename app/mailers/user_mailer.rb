class UserMailer < MandrillMailer::TemplateMailer
  default from: 'railsgirlssyd@gmail.com'

  def application_recieved(user)
    user_info = {name: user.name, email: user.email}

    mandrill_mail(
      template: 'application-recieved',
      subject: 'Thanks for applying!',
      to: user_info,
      vars: {
        'NAME' => user.name,
        'SUBJECT' => 'Thanks for applying!'
      },
      important: true,
      inline_css: true)
  end

  def application_success(user)
    user_info = {name: user.name, email:  user.email}

    mandrill_mail(
      template: 'application-successful',
      subject: 'Welcome to Rails Girls!',
      to: user_info,
      vars: {
        'NAME' => user.name,
        'SUBJECT' => 'Welcome to Rails Girls!',
        'ACCEPT_LINK' => user_status_url(user, 'accepted', port: 3000),
        'DELCLINE_LINK' => user_status_url(user, 'declined', port: 3000),
      },
      important: true,
      inline_css: true)
  end

  def application_rejected(user)
    user_info = {name: user.name, email: 'lucybain@gmail.com'}

    mandrill_mail(
      template: 'application-rejected',
      subject: 'Your Rails Girls application was not successful',
      to: user_info,
      vars: {
        'NAME' => user.name,
        'SUBJECT' => 'Your Rails Girls application was not successful'
      },
      important: true,
      inline_css: true)
  end

  def application_deferred(user)
    user_info = {name: user.name, email: 'lucybain@gmail.com'}

    mandrill_mail(
      template: 'application-deffered',
      subject: 'Rails Girls application still pending',
      to: user_info,
      vars: {
        'NAME' => user.name,
        'SUBJECT' => 'Rails Girls application still pending'
      },
      important: true,
      inline_css: true)
  end

end
