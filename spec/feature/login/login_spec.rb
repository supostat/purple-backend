require "rails_helper"

RSpec.describe "Login" do
  include Rack::Test::Methods
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user, :admin) }
  let(:login_url) { url_helpers.user_session_path }
  let(:valid_password) { user.password }
  let(:valid_email) { user.email }

  describe "with valid password and otp code" do
    let(:params) do
      {
        user: {
          email: valid_email,
          password: valid_password,
        }
      }
    end

    it "should sign in user" do
      otp_attempt = user.current_otp
      response = post(login_url, params.merge({otp_attempt: otp_attempt}))
      expect(response.status).to eq(200)
    end
  end

  private

  def app
    Rails.application
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
