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

      context '#issued_free_movie_ticket' do
        context 'when user issued free movie ticket' do
          before do
            user.issued_free_movie_ticket = true
            user.save
          end

          it 'should not issue free movie ticket' do
            expect_any_instance_of(Transaction).not_to receive(:issue_free_movie_ticket)

            transaction.save
          end
        end

        context 'when user did not issue free movie ticket' do
          it 'should issue free movie ticket' do
            expect_any_instance_of(Transaction).to receive(:issue_free_movie_ticket).once

            transaction.save
          end
        end
      end
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }
    let(:product) { create(:product) }

    let(:currency) { Transaction.currencies[:sgd] }

    let(:fee) { 0 } # NOTE: fee is 0 not determined yet in business logic but need it to  avoid flaky spec
    let(:transaction) { create(:transaction, user:, record: product, fee:, currency:) }

    before do
      allow(user.loyalty).to receive(:receive_point).and_return(nil)
      user.issued_free_movie_ticket = true
      user.issued_five_percentage_cash_rebate = true
      user.save
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
      before do
        user.issued_five_percentage_cash_rebate = true
        user.save
      end

      subject { transaction.send(:issue_five_percentage_cash_rebate_reward) }

      context 'with number transactions have amount gt 100 less than 10' do
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

      context 'with number transactions have amount gt 100 less than 10' do
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

    context '#issue_free_movie_ticket' do
      before do
        user.issued_free_movie_ticket = true
        user.save
      end

      subject { transaction.send(:issue_free_movie_ticket) }

      context 'with user spent fee more than 1000 but more than 60 days' do
        before do
          # first record
          create(:transaction, user:, record: product, fee: 300, currency:)

          # in 60 days
          create(:transaction, user:, record: product, fee: 200, currency:, created_at: Time.now + 50.days)
          create(:transaction, user:, record: product, fee: 200, currency:, created_at: Time.now + 59.days)

          # not in 60 days
          create(:transaction, user:, record: product, fee: 400, currency:, created_at: Time.now + 60.days)
        end

        it 'should not issue a new reward' do
          expect do
            subject
          end.not_to change(user.user_rewards, :count)
        end
      end

      context 'with user spent fee less than 1000 within 60 days' do
        before do
          # first record
          create(:transaction, user:, record: product, fee: 300, currency:)

          # in 60 days
          create(:transaction, user:, record: product, fee: 600, currency:, created_at: Time.now + 50.days)
        end

        it 'should not issue a new reward' do
          expect do
            subject
          end.not_to change(user.user_rewards, :count)
        end
      end

      context 'with user spent fee more than 1000 within 60 days' do
        before do
          # first record
          create(:transaction, user:, record: product, fee: 300, currency:)

          # in 60 days
          create(:transaction, user:, record: product, fee: 200, currency:, created_at: Time.now + 50.days)
          create(:transaction, user:, record: product, fee: 600, currency:, created_at: Time.now + 59.days)
        end

        it 'should issue a new reward' do
          expect do
            subject
          end.to change(user.user_rewards, :count).by(1)
        end

        it 'should issue cash rebate reward and update user reward meta' do
          subject

          expect(user.rewards.last.name).to eq('free_movie_ticket')
          expect(user.issued_free_movie_ticket).to be_truthy
        end
      end
    end

    context '#total_fee_in_quarter' do
      let(:user) { create(:user) }

      before do
        # 1st quarter
        user.transactions.create(fee: 200, created_at: "1/1/#{Time.now.year}", record: product)
        user.transactions.create(fee: 500, created_at: "8/2/#{Time.now.year}", record: product)
        user.transactions.create(fee: 600, created_at: "15/3/#{Time.now.year}", record: product)

        # 2nd quarter
        user.transactions.create(fee: 3000, created_at: "18/4/#{Time.now.year}", record: product)
        user.transactions.create(fee: 200, created_at: "22/5/#{Time.now.year}", record: product)
        user.transactions.create(fee: 600, created_at: "25/6/#{Time.now.year}", record: product)

        # 3rd quarter
        user.transactions.create(fee: 1000, created_at: "9/7/#{Time.now.year}", record: product)
        user.transactions.create(fee: 2000, created_at: "20/9/#{Time.now.year}", record: product)

        # 4th quarter
        user.transactions.create(fee: 100, created_at: "5/10/#{Time.now.year}", record: product)
        user.transactions.create(fee: 200, created_at: "2/12/#{Time.now.year}", record: product)
      end

      it 'return correct total fee in each quarter' do
        expect(described_class.total_fee_in_quarter(user, 1)).to eq(1300)
        expect(described_class.total_fee_in_quarter(user, 2)).to eq(3800)
        expect(described_class.total_fee_in_quarter(user, 3)).to eq(3000)
        expect(described_class.total_fee_in_quarter(user, 4)).to eq(300)
      end
    end
  end
end
