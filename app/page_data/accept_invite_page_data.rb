class AcceptInvitePageData
  Result = Struct.new(:user, :base64Png)

  def initialize(user:)
    @user = user
  end

  def call
    tfo_uri = GetOtpProvisioningURI.new(app_name: ENV.fetch("APP_NAME")).for_user(user)
    base64_png = Base64QrCodeFromString.call(string: tfo_uri)

    Result.new(user, base64_png)
  end

  private

  attr_reader :user
end
