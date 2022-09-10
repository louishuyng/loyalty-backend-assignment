require 'rails_helper'

RSpec.describe UserReward do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:reward) }
  end
end
