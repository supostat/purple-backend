require 'rails_helper'

RSpec.describe "InvitesIndexQuery" do
  let(:query) { InvitesIndexQuery.new(params: params) }
  let(:result) { query.all }
  let(:work_venues) { FactoryBot.create_list(:venue, 2) }

  context 'no filter params are supplied' do
    let(:params) { {} }

    context 'user exists not created from invite' do
      let!(:user) { FactoryBot.create(:user) }

      context 'before call' do
        specify '1 user should exist' do
          expect(User.count).to eq(1)
        end
      end

      it 'should not return user' do
        expect(result).to eq([])
      end
    end

    context 'user exists from invite' do
      let(:non_invite_user) { FactoryBot.create(:user) }
      let(:dummy_delivery_service) { double('invite delivery_service')}
      let(:venue) { FactoryBot.create(:venue) }
      let(:invite_user) do
        service_result = CreateInvite.new(
          inviter: non_invite_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: invite_params)

        raise "Couldn't invite user" unless service_result.success?
        service_result.invited_user
      end
      let(:invite_params) do
        {
          email: invite_user_email,
          first_name: 'joe',
          surname: 'lampost',
          role: Role::MANAGER_ROLE,
          venues_ids: invite_venues,
        }
      end
      let(:invite_user_email) { 'joe.lpost@fake.bom' }
      let(:invite_venues) { [venue.id]}

      before do
        allow(dummy_delivery_service).to receive(:call)
        invite_user
      end

      context 'before call' do
        specify '2 users should exist' do
          expect(User.count).to eq(2)
        end
      end

      it 'should return invite user' do
        expect(result.count).to eq(1)
        user = result.first
        expect(user.email).to eq(invite_user_email)
      end
    end
  end

  context 'filtering by role' do
    let(:params) { {role: filter_role} }

    context 'invited staff member exists' do
      let(:non_invite_user) { FactoryBot.create(:user) }
      let(:dummy_delivery_service) { double('invite delivery_service')}
      let(:venue) { FactoryBot.create(:venue) }
      let(:invite_user) do
        service_result = CreateInvite.new(
          inviter: non_invite_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: invite_params)

        raise "Couldn't invite user" unless service_result.success?
        service_result.invited_user
      end
      let(:invite_params) do
        {
          email: invite_user_email,
          first_name: 'joe',
          surname: 'lampost',
          role: invite_user_role,
          venues_ids: invite_venues,
        }
      end
      let(:invite_user_email) { 'joe.lpost@fake.bom' }
      let(:invite_venues) { [venue.id]}
      let(:manager_role) { Role.create!(name: Role::MANAGER_ROLE) }
      let(:admin_role) { Role.create!(name: Role::ADMIN_ROLE) }
      let(:roles) { [manager_role, admin_role] }

      before do
        roles
        allow(dummy_delivery_service).to receive(:call)
        invite_user
      end

      context 'with correct role' do
        let(:filter_role) { Role::MANAGER_ROLE }
        let(:invite_user_role) { filter_role }

        context 'before call' do
          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end
        end

        specify 'result should contain user' do
          expect(result).to eq([invite_user])
        end
      end

      context 'with incorrect role' do
        let(:filter_role) { Role::MANAGER_ROLE }
        let(:invite_user_role) { Role::ADMIN_ROLE }

        context 'before call' do
          specify 'role should not be filter role' do
            expect(invite_user_role).to_not eq(filter_role)
          end

          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end

          specify 'result should contain user' do
            expect(result).to eq([])
          end
        end
      end
    end
  end

  context 'filtering by email' do
    let(:params) { { email: filter_email } }

    context 'invited staff member exists' do
      let(:non_invite_user) { FactoryBot.create(:user) }
      let(:dummy_delivery_service) { double('invite delivery_service')}
      let(:venue) { FactoryBot.create(:venue) }
      let(:invite_user) do
        service_result = CreateInvite.new(
          inviter: non_invite_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: invite_params)

        raise "Couldn't invite user" unless service_result.success?
        service_result.invited_user
      end
      let(:invite_params) do
        {
          email: invite_user_email,
          first_name: 'joe',
          surname: 'lampost',
          role: invite_user_role,
          venues_ids: invite_venues,
        }
      end
      let(:invite_user_role) { Role::MANAGER_ROLE }
      let(:invite_venues) { [venue.id]}

      before do
        allow(dummy_delivery_service).to receive(:call)
        invite_user
      end

      context 'with correct email' do
        let(:filter_email) { 'person.im.looking.for@love.com' }
        let(:invite_user_email) { filter_email }

        context 'before call' do
          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end
        end

        specify 'result should contain user' do
          expect(result).to eq([invite_user])
        end
      end

      context 'with incorrect email' do
        let(:filter_email) { 'person.im.looking.for@love.com' }
        let(:invite_user_email) { 'someone.else@hate.net' }

        context 'before call' do
          specify 'role should not be filter role' do
            expect(invite_user_email).to_not eq(filter_email)
          end

          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end

          specify 'result should contain user' do
            expect(result).to eq([])
          end
        end
      end
    end
  end

  context 'filtering by venue' do
    let(:params) { { venues: [filter_venue] } }

    context 'invited staff member exists' do
      let(:non_invite_user) { FactoryBot.create(:user) }
      let(:dummy_delivery_service) { double('invite delivery_service')}
      let(:venue) { FactoryBot.create(:venue) }
      let(:invite_user) do
        service_result = CreateInvite.new(
          inviter: non_invite_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: invite_params)

        raise "Couldn't invite user" unless service_result.success?
        service_result.invited_user
      end
      let(:invite_params) do
        {
          venue: invite_user_venue,
          email: invite_user_email,
          first_name: 'joe',
          surname: 'lampost',
          venues_ids: invite_venues,
          role: invite_user_role,
        }
      end
      let(:invite_user_role) { Role::MANAGER_ROLE }
      let(:invite_user_email) { 'the@bomb.com' }
      let(:invite_venues) { [invite_user_venue.id] }

      before do
        allow(dummy_delivery_service).to receive(:call)
        invite_user
      end

      context 'with correct role' do
        let(:filter_venue) { invite_user_venue }
        let(:invite_user_venue) { FactoryBot.create(:venue, name: 'invite user venue') }

        context 'before call' do
          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end
        end

        specify 'result should contain user' do
          expect(result).to eq([invite_user])
        end
      end

      context 'with incorrect venue' do
        let(:filter_venue) { FactoryBot.create(:venue, name: 'filtervenue') }
        let(:invite_user_venue) { FactoryBot.create(:venue, name: 'invite venue') }

        context 'before call' do
          specify 'role should not be filter role' do
            expect(invite_user_venue).to_not eq(filter_venue)
          end

          specify '2 users should exist' do
            expect(User.count).to eq(2)
          end

          specify 'result should contain user' do
            expect(result).to eq([])
          end
        end
      end
    end
  end

  context 'filtering by status' do
    let(:params) { { status: filter_status } }

    context 'invited staff member exists' do
      let(:non_invited_user) { FactoryBot.create(:user) }
      let(:dummy_delivery_service) { double('invite delivery_service')}
      let(:invited_user_params) do
        {
          email: 'invited.user@fake.net',
          first_name: 'd',
          surname: 'user',
          venues_ids: invited_user_venues,
          role: invited_user_role,
        }
      end
      let(:invited_user) do
        service_result = CreateInvite.new(
          inviter: non_invited_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: invited_user_params)

        raise "Couldn't invited user" unless service_result.success?
        service_result.invited_user
      end
      let(:invited_user_role) { Role::MANAGER_ROLE }
      let(:invited_user_venue) { FactoryBot.create(:venue, name: 'user venue') }
      let(:revoked_user_params) do
        {
          email: 'revoked.user@fake.net',
          first_name: 'revoked',
          surname: 'user',
          venues_ids: invited_user_venues,
          role: invited_user_role,
        }
      end
      let(:revoked_user) do
        service_result = CreateInvite.new(
          inviter: non_invited_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: revoked_user_params)

        raise "Couldn't invited user" unless service_result.success?
        _result = service_result.invited_user
        # TODO: Use revoke service
        _result.update_attributes!(
          invitation_token: nil,
          invitation_revoked_at: 2.minutes.ago,
        )
        _result
      end
      let(:accepted_user_params) do
        {
          email: 'accepted.user@fake.net',
          first_name: 'accepted',
          surname: 'user',
          venues_ids: invited_user_venues,
          role: invited_user_role,
        }
      end
      let(:accepted_user) do
        service_result = CreateInvite.new(
          inviter: non_invited_user,
          invitiation_delivery_service: dummy_delivery_service,
        ).call(params: accepted_user_params)

        raise "Couldn't invited user" unless service_result.success?
        _result = service_result.invited_user
        _invitation_token = _result.raw_invitation_token
        auth_code = _result.current_otp
        _result = AcceptInvite.new.call(
          params: {
            invitation_token: _invitation_token,
            auth_code: auth_code,
            password: 'new_password',
            password_confirmation: 'new_password',
          }
        )
        raise "invite failed" unless _result.success?
        _result.user
      end
      let(:invited_user_venues) { [invited_user_venue.id] }

      before do
        allow(dummy_delivery_service).to receive(:call)
        invited_user
        revoked_user
        accepted_user
      end

      context 'before call' do
        specify '4 users should exist' do
          expect(User.count).to eq(4)
        end
      end

      context 'filtering by pending' do
        let(:filter_status) { User::INVITATION_PENDING_STATUS }

        specify 'should only return pending user' do
          expect(result).to eq([invited_user])
        end
      end

      context 'filtering by revoked status' do
        let(:filter_status) { User::INVITATION_REVOKED_STATUS }

        specify 'should only return revoked user' do
          expect(result).to eq([revoked_user])
        end
      end

      context 'filtering by accepted status' do
        let(:filter_status) { User::INVITATION_ACCEPTED_STATUS }

        specify 'should only return accepted user' do
          expect(result).to eq([accepted_user])
        end
      end
    end
  end
end
