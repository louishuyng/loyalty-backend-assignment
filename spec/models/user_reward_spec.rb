require 'rails_helper'

RSpec.describe UserReward do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reward) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:usage_amount) }
  end
end
