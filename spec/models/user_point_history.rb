require 'rails_helper'

RSpec.describe UserPointHistory do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:point) }
  end
end
