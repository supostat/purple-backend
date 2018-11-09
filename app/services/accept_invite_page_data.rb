class AcceptInvitePageData
  Result = Struct.new(:success, :user, :base64Png) do
    def success?
      success
    end
  end

  def initialize(invitation_token:)
    @invitation_token = invitation_token
  end

  def all
    success = false
    user = User.find_by_invitation_token(invitation_token, true)
    if user.present?
      issuer = ENV["APP_NAME"]
      label = "#{issuer}:#{user.email}"
      tfo_uri = user.otp_provisioning_uri(label, issuer: issuer)
      base64_png = Base64QrCodeFromString.call(string: tfo_uri)
      success = true
    end

    Result.new(success, user, base64_png)
  end

  private

  attr_reader :invitation_token
end
