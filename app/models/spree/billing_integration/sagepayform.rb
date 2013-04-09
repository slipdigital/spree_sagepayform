class Spree::BillingIntegration::Sagepayform < Spree::BillingIntegration
  preference :login, :string
  # preference :password, :string
  preference :encryption_key, :string

  # attr_accessible :preferred_login, :preferred_password, :preferred_server, :preferred_test_mode, :encryption_key
  attr_accessible :preferred_login, :preferred_server, :preferred_test_mode, :preferred_encryption_key, :preferred_notification_email


  def provider_class
    ActiveMerchant::Billing::Integrations::SagePayForm
  end

  def redirect_url(spfh)
    require "addressable/uri"
    uri = Addressable::URI.new
    uri.query_values = spfh.form_fields()
    "?" + uri.query
  end

  def set_global_options(opts)
    # add

  end

  def source_required?
    false
  end


end

