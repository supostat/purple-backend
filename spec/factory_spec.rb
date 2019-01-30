require 'rails_helper'

RSpec.describe "Factories" do
  describe "user factory" do
    it "should be valid" do
      expect(FactoryBot.create(:user)).to be_persisted
    end
  end

  describe 'venue factory' do
    it 'should be valid' do
      expect(FactoryBot.create(:venue)).to be_persisted
    end
  end
end
