class GetOtpProvisioningURI
  def initialize(app_name:)
    @app_name = app_name
  end
  attr_reader :app_name

  def for_user(user)
    label = "#{app_name}:#{user.email}"
    user.otp_provisioning_uri(label, issuer: app_name)
  end
end
