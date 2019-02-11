require "rails_helper"

RSpec.describe 'Accept invite endpoint' do
  include Rack::Test::Methods
  let(:url) { url_helpers.accept_api_v1_accept_invites_path }
  let(:response) { post(url, params)}
  let(:perform_call) { response }
  let(:params) do
    {
      invitationToken: invitation_token,
      authCode: auth_code,
      password: password,
      passwordConfirmation: password_confirmation,
    }
  end
  let(:inviter) { FactoryBot.create(:user, :admin) }
  let(:invited_user_venue) { FactoryBot.create(:venue) }
  let(:invite_user_response) do
    CreateInvite.new(
      inviter: inviter,
    ).call(params: {
      email: 'fake@shake.com',
      first_name: 'fake',
      surname: 'snakes',
      role: Role::MANAGER_ROLE,
      venues_ids: [invited_user_venue.id],
    })
  end
  let(:user) { invite_user_response.invited_user }
  let(:auth_code) { user.current_otp }
  let(:invitation_token) { user.raw_invitation_token }
  let(:password) { 'password' }
  let(:password_confirmation) { password }

  before do
    user
    auth_code
    invitation_token
  end

  context 'token is not valid' do
    let(:invitation_token) { 'invalid-token' }

    specify 'response should be unauthorised' do
      expect(response.status).to eq(unauthorised_status)
    end
  end

  context 'token is valid' do
    describe 'response' do
      specify 'should be success with empty body' do
        expect(response.status).to eq(ok_status)
      end

      specify 'should supply Authorization token in header' do
        expect(response.headers.fetch("Authorization")).to match(/^Bearer /)
      end
    end

    context 'authCode doesnt match' do
      let(:auth_code) { 'wrong auth code' }

      specify 'response should be Unprocessable Entity' do
        expect(response.status).to eq(unprocessable_status)
      end
    end

    context 'passwords dont match' do
      let(:password_confirmation) { "non matching password" }

      specify 'response should be Unprocessable Entity' do
        expect(response.status).to eq(unprocessable_status)
      end

      specify 'should return error json' do
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({
          "errors" => {
            "passwordConfirmation" => ["doesn't match Password"]
          }
        })
      end
    end
  end

  context 'invite is already accepted' do
    before do
      result = AcceptInvite.new.call(
        params: {
          invitation_token: invitation_token,
          auth_code: auth_code,
          password: 'new_password',
          password_confirmation: 'new_password',
        }
      )
      raise "Couldn't accept invite" unless result.success?
    end

    specify 'before call invite should be accepted' do
      expect(user.reload.invitation_accepted?).to eq(true)
    end

    specify 'response should be Unprocessable Entity' do
      expect(response.status).to eq(unauthorised_status)
    end
  end

  context 'invite is revoked' do
    before do
      user.update_attributes!(
        invitation_token: nil,
        invitation_revoked_at: 2.minutes.ago,
      )
    end

    specify 'before call user should be revoked' do
      expect(user.reload.invitation_revoked?).to eq(true)
    end

    specify 'response should be Unprocessable Entity' do
      expect(response.status).to eq(unauthorised_status)
    end
  end

  private
  def app
    Rails.application
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def ok_status
    200
  end

  def unauthorised_status
    401
  end

  def unprocessable_status
    422
  end
end
