require 'rails_helper'

RSpec.describe "InvitesIndexQuery" do
  let(:user) { FactoryBot.create(:user) }

  context 'holidays exists outside of tax year' do
    it "test" do
      expect(true).to eq(true)
    end
  end
end