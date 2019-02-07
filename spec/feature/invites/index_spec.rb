require "rails_helper"

RSpec.describe 'Accepting invite index endpoint' do
  include Rack::Test::Methods

  let(:url) { url_helpers.api_v1_accept_invites_path(params) }
  let(:inviter) { FactoryBot.create(:user) }
  let(:invited_user_venue) { FactoryBot.create(:venue).id }
  let(:mock_invitiation_delivery_service) { double("mock_invitiation_delivery_service") }
  let(:user) do
    _result = CreateInvite.new(
      inviter: inviter,
      invitiation_delivery_service: mock_invitiation_delivery_service,
    ).call(params: {
      email: 'fake@shake.com',
      first_name: 'fake',
      surname: 'snakes',
      role: Role::MANAGER_ROLE,
      venues: [invited_user_venue],
    })
    raise "Couldn't invite user" unless _result.success?
    _result.invited_user
  end

  before do
    allow(mock_invitiation_delivery_service).to receive(:call)
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
      let(:invitation_token) { user.raw_invitation_token }
      let(:user_tfo_uri) do
        GetOtpProvisioningURI.new(app_name: ENV.fetch("APP_NAME")).for_user(user)
      end

      describe 'result' do
        it 'should be succes' do
          expect(response.status).to eq(ok_status)
        end

        it 'should supply QR code and user data' do
          response_json = JSON.parse(response.body)

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
        expect{ peform_call }.to raise_error(ActiveRecord::RecordNotFound)
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
end
