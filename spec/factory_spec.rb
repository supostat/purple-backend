require 'rails_helper'

RSpec.describe "Factories" do
  describe "user factory" do
    it "should be valid" do
      created_user = FactoryBot.create(:user)
      expect(created_user).to be_persisted
    end

    it 'should not register as invited' do
      created_user = FactoryBot.create(:user)
      expect(created_user.created_by_invite?).to eq(false)
    end
  end

  describe 'venue factory' do
    it 'should be valid' do
      expect(FactoryBot.create(:venue)).to be_persisted
    end
  end
end
