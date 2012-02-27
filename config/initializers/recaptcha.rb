Paper::Application.config.middleware.use Rack::Recaptcha, { 
  :public_key  => Paper.config.recaptcha.public_key,
  :private_key => Paper.config.recaptcha.private_key
}