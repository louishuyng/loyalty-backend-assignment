require 'rails_helper'

RSpec.describe UserLoyalty do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'settings' do
    it do
      values = {
        standard: 'standard',
        gold: 'gold',
        platinum: 'platinum',
      }

      expect(subject).to define_enum_for(:tier).with_values(values).backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tier) }
    it { is_expected.to validate_presence_of(:accumulate_point) }
  end
end
