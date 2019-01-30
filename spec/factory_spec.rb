require 'rails_helper'

RSpec.describe "Factories" do
  describe "user factory" do
    it "should be valid" do
      expect(FactoryBot.build(:user)).to be_valid
    end
  end

  describe 'venue factory' do
    it 'should be valid' do
      expect(FactoryBot.build(:venue)).to be_valid
    end
  end
end
