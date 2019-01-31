class AcceptInvitePageData
  Result = Struct.new(:user, :base64Png)

  def initialize(invitation_token:)
    @invitation_token = invitation_token
  end

  def call
    user = User.find_by_invitation_token(invitation_token, true)
    if !user.present?
      raise ActiveRecord::RecordNotFound
    end

    issuer = ENV.fetch("APP_NAME")
    label = "#{issuer}:#{user.email}"
    tfo_uri = user.otp_provisioning_uri(label, issuer: issuer)
    base64_png = Base64QrCodeFromString.call(string: tfo_uri)

    Result.new(user, base64_png)
  end

  private

  attr_reader :invitation_token
end
