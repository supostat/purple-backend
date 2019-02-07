require "rails_helper"

RSpec.describe ResetPassword, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user, work_venues: work_venues) }
  let(:work_venues) { FactoryBot.create_list(:venue, 10) }
  let(:service) { ResetPassword.new }

  describe "when valid params" do
    let(:token) { user.send_reset_password_instructions }
    let(:params) do
      {
        token: token,
        password: "new_password",
        password_confirmation: "new_password",
      }
    end
    let(:result) { service.call(params: params) }

    it "should reset password" do
      expect(result.success?).to eq(true)
    end
  end
  describe "when invalid params" do
    let(:token) { "invalid_token" }
    let(:params) do
      {
        token: token,
        password: "new_password",
        password_confirmation: "new_password",
      }
    end
    let(:result) { service.call(params: params) }

    it "should not reset password" do
      expect(result.success?).to eq(false)
    end
  end
  describe "when token expired" do
    let!(:token) { user.send_reset_password_instructions }
    let(:params) do
      {
        token: token,
        password: "new_password",
        password_confirmation: "new_password",
      }
    end
    let(:result) { service.call(params: params) }

    it "should not reset password" do
      travel 7.hours
      expect(result.success?).to eq(false)
    end
  end
end
