require 'rails_helper'

RSpec.describe Product do
  describe 'associations' do
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
