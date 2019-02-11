require "rails_helper"

RSpec.describe 'Accepting invite index endpoint' do
  include Rack::Test::Methods

  let(:url) { url_helpers.api_v1_accept_invites_path(params) }
  let(:inviter) { FactoryBot.create(:user, :admin) }
  let(:invited_user_venue) { FactoryBot.create(:venue).id }
  let(:created_by_invite_result) do
    _result = CreateInvite.new(
      inviter: inviter,
    ).call(params: {
      email: 'fake@shake.com',
      first_name: 'fake',
      surname: 'snakes',
      role: Role::MANAGER_ROLE,
      venues_ids: [invited_user_venue],
    })
    raise "Couldn't invite user" unless _result.success?
    _result
  end
  let(:user) do
    created_by_invite_result.invited_user
  end
  let(:invitation_token) do
    user.raw_invitation_token
  end

  before do
    user
  end

  context 'before call' do
    specify '2 users should exist' do
      expect(User.count).to eq(2)
    end
  end

  context 'after call' do
    let(:response) { get(url, params) }
    let(:peform_call) { response }
    let(:params) do
      {
        invitationToken: invitation_token,
      }
    end

    context 'when token is valid' do
      let(:user_tfo_uri) do
        GetOtpProvisioningURI.new(
          app_name: ENV.fetch("APP_NAME")
        ).for_user(user)
      end

      describe 'result' do
        it 'should be success' do
          expect(response.status).to eq(ok_status)
        end

        it 'should supply QR code and user data' do
          response_json = body_as_json(response.body)
          expect(response_json).to eq({
            "base64Png" => Base64QrCodeFromString.call(string: user_tfo_uri),
            "invitedUser" => {
              "email" =>  user.email,
              "firstName" => user.first_name,
              "surname" => user.surname,
            },
          })
        end
      end
    end

    context 'when token is invalid' do
      let(:invitation_token) { 'invalid_token' }

      specify 'supply QR code and user data' do
        expect(response.status).to eq(forbidden_status)
      end
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

  def forbidden_status
    403
  end
end
