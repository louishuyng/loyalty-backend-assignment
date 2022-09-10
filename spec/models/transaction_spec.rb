require 'rails_helper'

RSpec.describe Transaction do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:record) }
  end

  describe 'settings' do
    it do
      values = {
        pending: 'pending',
        reject: 'reject',
        fulfill: 'fulfill',
      }

      expect(subject).to define_enum_for(:status).with_values(values).backed_by_column_of_type(:string).with_prefix
    end

    it do
      values = {
        sgd: 'sgd',
        vnd: 'vnd',
        usd: 'usd',
      }

      expect(subject).to define_enum_for(:currency).with_values(values).backed_by_column_of_type(:string)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_presence_of(:currency) }
  end
end
