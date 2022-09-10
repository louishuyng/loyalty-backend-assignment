require 'rails_helper'

RSpec.describe Reward do
  describe 'associations' do
    it { is_expected.to have_many(:user_rewards).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_rewards) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
