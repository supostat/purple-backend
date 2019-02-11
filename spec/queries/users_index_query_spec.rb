require "rails_helper"

RSpec.describe "InvitesIndexQuery" do
  let!(:user) {
    FactoryBot.create(:user,
                      :admin,
                      :disabled,
                      first_name: "Firstname",
                      surname: "Surname",
                      email: "some_email@mail.com")
  }
  let(:query_service) { UsersIndexQuery.new(params: params) }

  describe "First name and surname" do
    describe "half first name and half surname" do
      let(:params) do
        {
          name: "First sur",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "half first name" do
      let(:params) do
        {
          name: "First",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "half surname" do
      let(:params) do
        {
          name: "sur",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "Full name" do
      let(:params) do
        {
          name: "Firstname Surname",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "with random capitals" do
      let(:params) do
        {
          name: "FiRstNamE SURNAme",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "with wrong name" do
      let(:params) do
        {
          name: "wrong name",
        }
      end

      let(:result) { query_service.all }

      it "should not return user" do
        expect(result.count).to eq(0)
      end
    end
  end
  describe "Email" do
    describe "domain only" do
      let(:params) do
        {
          email: "mail.com",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "email name only" do
      let(:params) do
        {
          email: "some_email",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "half email name" do
      let(:params) do
        {
          email: "some",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
    describe "last half email name" do
      let(:params) do
        {
          email: "email",
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
  end
  describe "Status" do
    describe "enabled" do
      let(:params) do
        {
          status: User::ENABLED_STATUS,
        }
      end

      let(:result) { query_service.all }

      it "should not return user" do
        expect(result[0].id).to eq(user.disabled_by_user.id)
      end
    end

    describe "disabled" do
      let(:params) do
        {
          status: User::DISABLED_STATUS,
        }
      end

      let(:result) { query_service.all }

      it "should return user" do
        expect(result[0].id).to eq(user.id)
      end
    end
  end
end
