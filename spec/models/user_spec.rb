require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:user_rewards).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:point_histories).class_name('UserPointHistory').dependent(:destroy) }

    it { is_expected.to have_many(:rewards).through(:user_rewards) }

    it { is_expected.to have_one(:loyalty).class_name('UserLoyalty').inverse_of(:user).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_name) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
