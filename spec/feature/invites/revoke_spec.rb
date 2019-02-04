require "rails_helper"

RSpec.describe 'Revoke invite endpoint' do
  include Rack::Test::Methods

  let(:url) { url_helpers.revoke_api_v1_invite_path(id: query_id) }
  let(:response) { post(url, params)}
  let(:perform_call) { response }
  let(:params) { {} }
  let(:inviter) { FactoryBot.create(:user, roles: [manager_role]) }
  let(:invited_user_venue) { FactoryBot.create(:venue) }
  let(:mock_invitiation_delivery_service) { double("mock_invitiation_delivery_service") }
  let(:manager_role) { Role.create!(name: Role::MANAGER_ROLE) }
  let(:invite_user_response) do
    _result = CreateInvite.new(
      inviter: inviter,
      invitiation_delivery_service: mock_invitiation_delivery_service,
    ).call(params: {
      email: 'fake@shake.com',
      first_name: 'fake',
      surname: 'snakes',
      role: manager_role.name,
      venues: [invited_user_venue],
    })
    raise 'invite could not be created' unless _result.success?
    _result
  end
  let(:user) { invite_user_response.invited_user }
  let(:invitation_token) { user.raw_invitation_token }

  before do
    manager_role
    allow(mock_invitiation_delivery_service).to receive(:call)
    set_authorization_header(inviter)
  end

  context 'before call' do
    specify 'user should be invited' do
      expect(user.invitation_revoked?).to eq(false)
      expect(user.invited_to_sign_up?).to eq(true)
    end
  end

  context 'incorrect id is supplied' do
    let(:query_id) { 3424 }

    specify do
      expect{ perform_call }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'correct id is supplied' do
    let(:query_id) { user.id }

    specify 'should be success' do
      expect(response.status).to eq(ok_status)
    end

    specify 'should return empty response' do
      response_json = JSON.parse(response.body)
      expect(response_json).to eq({})
    end

    specify 'user should be revoked' do
      perform_call
      expect(user.reload.invitation_revoked?).to eq(true)
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
