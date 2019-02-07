require "rails_helper"

RSpec.describe Api::V1::UsersController, type: :controller do
  include HeaderHelpers

  let(:user) { FactoryBot.create(:user, :manager, work_venues: venues) }
  let(:requester) { FactoryBot.create(:user, :manager, work_venues: venues) }
  let(:venues) { FactoryBot.create_list(:venue, 10) }
  let(:venues_ids_to_update) { venues.take(2).map(&:id) }

  before do
    set_controller_spec_headers(requester)
  end

  describe "when update personal details" do
    def trigger
      post :update_personal_details, params: {id: user.id}.merge(params)
    end

    describe "with valid params" do
      let(:params) do
        {
          firstName: "New First name",
          surname: "New Surname",
          email: "new@email.com",
        }
      end

      it "returns http success" do
        trigger
        expect(response).to have_http_status(:success)
      end

      it "update user personal details" do
        trigger
        updated_user = body_as_json.fetch(:user)
        expect(response).to have_http_status(:success)
      end

      it "respond body JSON with attributes" do
        trigger
        expect(response.body).to look_like_json
        expect(body_as_json).to be_kind_of(Hash)
      end

      it "correct user attributes are rendered" do
        expect_any_instance_of(Api::V1::Users::UserSerializer).to receive(:as_json).and_call_original
        trigger
        user_id = body_as_json
          .fetch(:user)
          .fetch(:id)
          .to_i

        expect(user_id).to eq user.id
      end
    end

    describe "with empty params" do
      let(:params) do
        {
          firstName: "",
          surname: "",
          email: "",
        }
      end

      it "returns http unprocessable entity" do
        trigger
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "respond body JSON with attributes" do
        trigger
        expect(response.body).to look_like_json
        expect(body_as_json).to be_kind_of(Hash)
      end

      it "errors are rendered" do
        expect_any_instance_of(UpdateUserPersonalDetailsApiErrors).to receive(:errors).and_call_original
        trigger
        errors = body_as_json.fetch(:errors)
        expect(errors[:firstName]).to eq(["can't be blank"])
        expect(errors[:surname]).to eq(["can't be blank"])
        expect(errors[:email]).to eq(["can't be blank"])
      end
    end
  end

  describe "when update access details" do
    def trigger
      post :update_access_details, params: {id: user.id}.merge(params)
    end

    describe "with valid params" do
      let(:params) {
        {
          role: Role::MANAGER_ROLE,
          venues: venues_ids_to_update,
        }
      }
      it "returns http success" do
        trigger
        expect(response).to have_http_status(:success)
      end

      it "update user personal details" do
        trigger
        user.reload
        expect(user.roles_name[0]).to eq(Role::MANAGER_ROLE)
        expect(user.work_venues.map(&:id)).to eq(venues_ids_to_update)
      end

      it "respond body JSON with attributes" do
        trigger
        expect(response.body).to look_like_json
        expect(body_as_json).to be_kind_of(Hash)
      end

      it "correct user attributes are rendered" do
        expect_any_instance_of(Api::V1::Users::UserSerializer).to receive(:as_json).and_call_original
        trigger
        user_id = body_as_json
          .fetch(:user)
          .fetch(:id)
          .to_i

        expect(user_id).to eq user.id
      end
    end

    describe "with empty params" do
      let(:params) {
        {
          role: nil,
          venues: [],
        }
      }
      it "returns http unprocessable entity" do
        trigger
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "respond body JSON with attributes" do
        trigger
        expect(response.body).to look_like_json
        expect(body_as_json).to be_kind_of(Hash)
      end

      it "errors are rendered" do
        expect_any_instance_of(UpdateUserAccessDetailsApiErrors).to receive(:errors).and_call_original
        trigger
        errors = body_as_json.fetch(:errors)
        expect(errors[:role]).to eq(["can't be blank", "is not included in the list"])
      end
    end
  end

  describe "when disable" do
    def trigger
      post :disable, params: {id: user.id}.merge(params)
    end

    let(:never_rehire) { false }

    describe "before call" do
      it "user should be enabled" do
        expect(user.disabled?).to eq(false)
      end
      it "user should not be flagged" do
        expect(user.flagged?).to eq(false)
      end
    end

    describe "with valid params" do
      let(:params) { {disabledReason: "Some reason", neverRehire: never_rehire} }

      describe "when never rehire is true" do
        let(:never_rehire) { true }
        it "returns http success" do
          trigger
          expect(response).to have_http_status(:success)
        end

        it "user should be disabled" do
          trigger
          user.reload
          expect(user.disabled?).to eq(true)
        end

        it "user should not be flagged" do
          trigger
          user.reload
          expect(user.flagged?).to eq(true)
        end
      end

      describe "when never rehire is false" do
        let(:never_rehire) { false }
        it "returns http success" do
          trigger
          expect(response).to have_http_status(:success)
        end

        it "user should be disabled" do
          trigger
          user.reload
          expect(user.disabled?).to eq(true)
        end

        it "user should not be flagged" do
          trigger
          user.reload
          expect(user.flagged?).to eq(false)
        end
      end

      it "correct user attributes are rendered" do
        expect_any_instance_of(Api::V1::Users::UserSerializer).to receive(:as_json).and_call_original
        trigger
        user_id = body_as_json
          .fetch(:user)
          .fetch(:id)
          .to_i

        expect(user_id).to eq user.id
      end
    end

    describe "with invalid params" do
      let(:params) { {disabledReason: "", neverRehire: nil} }

      it "returns http unprocessable entity" do
        trigger
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "user should not be disabled" do
        trigger
        user.reload
        expect(user.disabled?).to eq(false)
      end

      it "user should not be flagged" do
        trigger
        user.reload
        expect(user.flagged?).to eq(false)
      end

      it "correct user attributes are rendered" do
        expect_any_instance_of(DisableUserApiErrors).to receive(:errors).and_call_original
        trigger
      end
    end
  end

  describe "when enable" do
    let(:user) { FactoryBot.create(:user, :manager, :disabled, work_venues: venues) }

    def trigger
      post :enable, params: {id: user.id}
    end

    describe "before call" do
      it "user should be disabled" do
        expect(user.disabled?).to eq(true)
      end
    end

    describe "should enable user" do
      it "returns http success" do
        trigger
        expect(response).to have_http_status(:success)
      end

      it "user should be enabled" do
        trigger
        user.reload
        expect(user.disabled?).to eq(false)
      end

      it "correct user attributes are rendered" do
        expect_any_instance_of(Api::V1::Users::UserSerializer).to receive(:as_json).and_call_original
        trigger
        user_id = body_as_json
          .fetch(:user)
          .fetch(:id)
          .to_i

        expect(user_id).to eq user.id
      end
    end
  end

  describe "when get history" do
    let(:user) {
      FactoryBot.create(:user, :manager,
                        first_name: old_first_name,
                        surname: old_surname,
                        email: old_email,
                        work_venues: old_venues)
    }
    let(:old_venues) { FactoryBot.create_list(:venue, 10) }
    let(:old_email) { "old@email.com" }
    let(:old_first_name) { "Oldfirstname" }
    let(:old_surname) { "Oldsurname" }
    let!(:old_role) { user.roles_name[0] }

    let(:update_personal_details_params) do
      {
        id: user.id,
        first_name: "New First name",
        surname: "New Surname",
        email: "new@email.com",
      }
    end

    let(:update_access_details_params) do
      {
        id: user.id,
        role: Role::ADMIN_ROLE,
        work_venues_ids: venues_ids_to_update,
      }
    end

    def make_user_changes
      UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params)
      UpdateUserAccessDetails.new(requester: requester).call(params: update_access_details_params)
    end

    def trigger
      get :history, params: {id: user.id}
    end

    describe "before call" do
      it "no history should exist" do
        expect(user.history.count).to eq(0)
      end
    end

    describe "after making user changes" do
      it "should change user history" do
        make_user_changes
        trigger
        user.reload
        user_history = body_as_json.fetch(:history)
        user_history.each do |history|
          key = history.fetch(:key)
          old_value = history.fetch(:oldValue)
          new_value = history.fetch(:newValue)
          if key === "email"
            expect(old_value).to eq(old_email)
            expect(new_value).to eq(user.email)
          end
          if key === "first_name"
            expect(old_value).to eq(old_first_name)
            expect(new_value).to eq(user.first_name)
          end
          if key === "surname"
            expect(old_value).to eq(old_surname)
            expect(new_value).to eq(user.surname)
          end
          if key === "role"
            expect(old_value).to eq(old_role)
            expect(new_value).to eq(user.roles_name[0])
          end
          if key === "work_venues"
            old_data = old_venues.map {|venue| { id: venue.id, name: venue.name }}
            user_current_data = user.work_venues.map {|venue| { id: venue.id, name: venue.name }}

            old_history_data = JSON.parse(old_value)
            new_history_data = JSON.parse(new_value)

            old_history_data.each_with_index do |history, index|
              expect(history["id"]).to eq(old_data[index][:id])
              expect(history["name"]).to eq(old_data[index][:name])
            end
            new_history_data.each_with_index do |history, index|
              expect(history["id"]).to eq(user_current_data[index][:id])
              expect(history["name"]).to eq(user_current_data[index][:name])
            end
          end
        end
        expect(user_history.count).to eq(5)
      end
    end
  end
end
