require "rails_helper"

RSpec.describe "UserProfileHistoryQuery" do
  include ActiveSupport::Testing::TimeHelpers

  let(:query) { UserProfileHistoryQuery.new(params: params) }
  let(:now) { Time.current }
  let!(:user) do
    travel_to now-100.days
    FactoryBot.create(:user, :manager, work_venues: venues)
  end
  let(:requester) { FactoryBot.create(:user, :manager, work_venues: venues) }
  let(:venues) { FactoryBot.create_list(:venue, 10) }

  let(:update_personal_details_params) do
    {
      id: user.id,
      surname: user.surname,
      email: user.email,
    }
  end

  def make_user_changes
    travel_to now - 90.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 80.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 70.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 60.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 50.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 40.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 30.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 20.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 10.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
    travel_to now - 5.days
    UpdateUserPersonalDetails.new(requester: requester).call(params: update_personal_details_params.merge({first_name: Faker::Name.first_name}))
  end

  describe "before call" do
    let(:params) { {id: user.id} }
    it "no history should exist" do
      expect(query.all.count).to eq(0)
    end
  end

  describe "no filter params are supplied" do
    let(:params) { {id: user.id} }

    it "result should have a history" do
      make_user_changes
      expect(query.all.count).to eq(10)
    end
  end

  describe "with start and end date, all records in range" do
    let(:params) { {id: user.id, start_date: UIDate.format(now - 90.days), end_date: UIDate.format(now)} }

    it "result should have a history" do
      make_user_changes
      expect(query.all.count).to eq(10)
    end
  end

  describe "with start and end date, some records in range" do
    let(:params) { {id: user.id, start_date: UIDate.format(now - 40.days), end_date: UIDate.format(now)} }

    it "result should have a history" do
      make_user_changes
      expect(query.all.count).to eq(5)
    end
  end

  describe "with start and end date, no records in range" do
    let(:params) { {id: user.id, start_date: UIDate.format(now - 200.days), end_date: UIDate.format(now - 100.days)} }

    it "result should not have a history" do
      make_user_changes
      expect(query.all.count).to eq(0)
    end
  end

  describe "when starts_at only exist" do
    let(:params) { {id: user.id, start_date: UIDate.format(now - 200.days)} }

    it "result should have a history" do
      make_user_changes
      expect(query.all.count).to eq(10)
    end
  end

  describe "when ends_at only exist" do
    let(:params) { {id: user.id, end_date: UIDate.format(now)} }

    it "result should have a history" do
      make_user_changes
      expect(query.all.count).to eq(10)
    end
  end
end
