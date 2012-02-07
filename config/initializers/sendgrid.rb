if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :user_name            => ENV['SENDGRID_USERNAME'],
    :password             => ENV['SENDGRID_PASSWORD'],
    :domain               => Paper.config.host,
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end