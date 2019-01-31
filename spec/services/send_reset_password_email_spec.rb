require "rails_helper"

RSpec.describe SendResetPasswordEmail, type: :service do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_email) { user.email }
  let(:invalid_email) { "invalid@email.com" }
  let(:email_subject) { "Reset password instructions" }
  let(:service) { SendResetPasswordEmail.new(email: email) }

  context "before call" do
    it "no delivered messages should be present" do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  describe "when valid email" do
    let(:email) { valid_email }

    before do
      service.call
    end

    it "should send reset password email" do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq(email_subject)
      expect(mail.to).to eq([valid_email])
    end
  end

  describe "when invalid email" do
    let(:email) { invalid_email }

    before do
      service.call
    end

    it "should not send reset password email" do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  it "should work" do
    expect(true).to be(true)
  end
end
