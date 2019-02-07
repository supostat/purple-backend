require "rails_helper"

RSpec.describe Api::V1::PasswordsController do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { FactoryBot.create(:user, work_venues: work_venues) }
  let(:work_venues) { FactoryBot.create_list(:venue, 10) }
  let(:email_subject) { "Reset password instructions" }
  let(:valid_email) { user.email }
  let(:invalid_email) { "invalid@email.com" }

  context "before call" do
    it "no delivered messages should be present" do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end

  describe "when send reset password" do
    describe "when email valid" do
      it "should be success" do
        post :send_reset_password_email, params: { email: valid_email }
        expect(body_as_json).to eq({})
        expect(response).to have_http_status(ok_status)
      end
      describe "email" do
        it "with reset password link should be send" do
          post :send_reset_password_email, params: { email: valid_email }
          expect(ActionMailer::Base.deliveries.count).to eq(1)
          mail = ActionMailer::Base.deliveries.last
          expect(mail.subject).to eq(email_subject)
          expect(mail.to).to eq([user.email])
        end
      end

      describe "reset password period" do
        it "should be valid" do
          post :send_reset_password_email, params: { email: valid_email }
          user.reload
          expect(user.reset_password_period_valid?).to eq(true)
        end
        it "after 6 hours should be invalid" do
          post :send_reset_password_email, params: { email: valid_email }
          user.reload
          travel 7.hours
          expect(user.reset_password_period_valid?).to eq(false)
        end
      end
    end
    describe "when email invalid" do
      it "should be success" do
        post :send_reset_password_email, params: {email: invalid_email}
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({})
        expect(response).to have_http_status(ok_status)
      end

      describe "email" do
        it "with reset password link should not be send" do
          post :send_reset_password_email, params: {email: invalid_email}
          expect(ActionMailer::Base.deliveries.count).to eq(0)
        end
      end

      describe "reset password period" do
        it "should not be created" do
          post :send_reset_password_email, params: {email: invalid_email}
          user.reload
          expect(user.reset_password_period_valid?).to eq(nil)
        end
      end
    end
  end

  describe "when reset password" do
    let(:valid_token) { user.send_reset_password_instructions }

    describe "with valid params" do
      let(:password) { "new_password" }
      let(:password_confirmation) { "new_password" }

      it "should reset password" do
        post :reset_password, params: {token: valid_token, password: password, passwordConfirmation: password_confirmation}
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(ok_status)
        expect(json_response).to eq({})
      end
    end

    describe "with invalid params" do
      let(:invalid_token) { "wrong_token" }
      let(:password) { "new_password" }
      let(:password_confirmation) { "new_password" }

      describe "when token invalid" do
        it "should send base validation error" do
          post :reset_password, params: {token: invalid_token, password: password, passwordConfirmation: password_confirmation}
          json_response = JSON.parse(response.body)
          errors = json_response["errors"]
          expect(response).to have_http_status(unprocessable_entity_status)
          expect(errors["base"]).to eq(["Token is invalid"])
        end
      end

      describe "when passwords do not match" do
        let(:password) { "new_password" }
        let(:password_confirmation) { "new_password2" }

        it "should send password confirmation validation error" do
          post :reset_password, params: {token: valid_token, password: password, passwordConfirmation: password_confirmation}
          json_response = JSON.parse(response.body)
          errors = json_response["errors"]
          expect(response).to have_http_status(unprocessable_entity_status)
          expect(errors["passwordConfirmation"]).to eq(["doesn't match Password"])
        end
      end

      describe "when passwords is too short" do
        let(:password) { "1" }
        let(:password_confirmation) { "1" }

        it "should send password validation error" do
          post :reset_password, params: {token: valid_token, password: password, passwordConfirmation: password_confirmation}
          json_response = JSON.parse(response.body)
          errors = json_response["errors"]
          expect(response).to have_http_status(unprocessable_entity_status)
          expect(errors["password"]).to eq(["is too short (minimum is 6 characters)"])
        end
      end

      describe "when token expired" do
        let(:password) { "new_password" }
        let(:password_confirmation) { "new_password" }

        it "should send password validation error" do
          valid_token = user.send_reset_password_instructions

          travel 10.hours

          post :reset_password, params: {token: valid_token, password: password, passwordConfirmation: password_confirmation}
          json_response = JSON.parse(response.body)
          errors = json_response["errors"]
          expect(response).to have_http_status(unprocessable_entity_status)
          expect(errors["base"]).to eq(["Token has expired, please request a new one"])
        end
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def ok_status
    200
  end

  def unprocessable_entity_status
    422
  end
end
