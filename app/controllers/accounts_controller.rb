class AccountsController < Devise::RegistrationsController
  
  include Rack::Recaptcha::Helpers
  helper_method :recaptcha_tag
  
  def create
    if recaptcha_valid?
      super
    else
      build_resource
      resource.valid?
      resource.errors.add(:base, t('recaptcha.invalid'))
      clean_up_passwords resource
      respond_with resource
    end
  end
end