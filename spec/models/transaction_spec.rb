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

      expect(subject).to define_enum_for(:currency).with_values(values).backed_by_column_of_type(:string).with_prefix
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:fee) }
    it { is_expected.to validate_presence_of(:currency) }
  end

  describe 'callback' do
    describe 'after_create' do
      let(:user) { create(:user) }
      let(:product) { create(:product) }

      let(:transaction) { build(:transaction, user:, record: product) }

      before do
        allow_any_instance_of(Transaction).to receive(:update_user_loyalty).and_return(nil)
      end

      it 'call update_user_loyalty once' do
        expect_any_instance_of(Transaction).to receive(:update_user_loyalty).once

        transaction.save
      end
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }
    let(:product) { create(:product) }

    let(:fee) { 10 }
    let(:currency) { Transaction.currencies[:sgd] }

    let(:transaction) { create(:transaction, user:, record: product, fee:, currency:) }

    before do
      allow(user.loyalty).to receive(:receive_point).and_return(nil)
    end

    context '#update_user_loyalty' do
      subject { transaction.update_user_loyalty }

      context 'with fee paid by local currency' do
        it 'call loyalty receive_point with correct point' do
          expect(user.loyalty).to receive(:receive_point).with(fee / Transaction::FEE_TO_ACHIVE_STANDARD_POINT)

          subject
        end
      end

      context 'with fee paid by foregin currency' do
        let(:currency) { Transaction.currencies[:vnd] }

        it 'call loyalty receive_point with dobule standard point' do
          expect(user.loyalty).to receive(:receive_point).with(UserLoyalty::STANDARD_POINT * 2)

          subject
        end
      end
    end
  end
end
