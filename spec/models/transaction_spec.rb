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
        allow_any_instance_of(Transaction).to receive(:issue_five_percentage_cash_rebate_reward).and_return(nil)
      end

      context '#update_user_loyalty' do
        it 'call update_user_loyalty once' do
          expect_any_instance_of(Transaction).to receive(:update_user_loyalty).once

          transaction.save
        end
      end

      context '#issue_five_percentage_cash_rebate_reward' do
        context 'when user issued bash rebate reward' do
          before do
            user.issued_five_percentage_cash_rebate = true
            user.save
          end

          it 'should not issue cash rebate reward' do
            expect_any_instance_of(Transaction).not_to receive(:issue_five_percentage_cash_rebate_reward)

            transaction.save
          end
        end

        context 'when user did not issue bash rebate reward' do
          it 'should issue cash rebate reward' do
            expect_any_instance_of(Transaction).to receive(:issue_five_percentage_cash_rebate_reward).once

            transaction.save
          end
        end
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

    context '#issue_five_percentage_cash_rebate_reward' do
      subject { transaction.send(:issue_five_percentage_cash_rebate_reward) }

      context 'with number transactions have amoun gt 100 less than 10' do
        before do
          10.times do
            create(:transaction, user:, record: product, fee: 100, currency:)
          end
        end

        it 'should not issue a new reward' do
          expect do
            subject
          end.not_to change(user.user_rewards, :count)
        end
      end

      context 'with number transactions have amoun gt 100 less than 10' do
        before do
          10.times do
            create(:transaction, user:, record: product, fee: 110, currency:)
          end
        end

        it 'should issue a new reward' do
          expect do
            subject
          end.to change(user.user_rewards, :count).by(1)
        end

        it 'should issue cash rebate reward and update user reward meta' do
          subject

          expect(user.rewards.last.name).to eq('5_percentage_cash_rebate')
          expect(user.issued_five_percentage_cash_rebate).to be_truthy
        end
      end
    end
  end
end
