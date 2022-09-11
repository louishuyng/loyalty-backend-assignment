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

      expect(subject).to define_enum_for(:tier).with_values(values).backed_by_column_of_type(:string).with_prefix
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tier) }
    it { is_expected.to validate_presence_of(:current_point) }
    it { is_expected.to validate_presence_of(:accumulate_point) }
  end

  describe 'callback' do
    describe 'after_create' do
      let(:user) { create(:user) }
      let(:user_loyalty) { create(:user_loyalty, current_point: 0, user:) }

      context '#up_tier_process' do
        context 'up_to_gold_tier' do
          subject {  user_loyalty.update(current_point: 2000) }
          it 'should update the tier to gold when matching point' do
            subject

            expect(user_loyalty.reload.tier).to eq(UserLoyalty.tiers[:gold])
          end

          context 'user got gold reward' do
            before do
              user.issued_gold_reward = true
              user.save
            end

            it 'should not receive airport_lounge_access' do
              expect do
                subject
              end.not_to change(user.user_rewards, :count)
            end
          end

          context 'user did not get gold reward' do
            it 'should receive 4x airport_lounge_access' do
              expect do
                subject
              end.to change(user.user_rewards, :count).by(1)

              subject

              expect(user.rewards.last.name).to eq('airport_lounge_access')
              expect(user.user_rewards.last.usage_amount).to eq(4)
              expect(user.issued_gold_reward).to be_truthy
            end
          end
        end

        it 'should update the tier to platinum when matching point' do
          user_loyalty.update(current_point: 6000)

          expect(user_loyalty.reload.tier).to eq(UserLoyalty.tiers[:platinum])
        end
      end
    end
  end

  describe 'methods' do
    let(:accumulate_point) { 0 }
    let(:current_point) { 20 }

    let(:user) { create(:user) }

    # fake users for testing reset point and tiers
    let(:user_one) { create(:user) }
    let(:user_two) { create(:user) }
    let(:user_three) { create(:user) }

    let(:user_loyalty) { create(:user_loyalty, current_point:, accumulate_point:, user:) }

    context '#receive_point' do
      let(:limit_point_to_reach_standard) { 3 }
      let(:accumulate_point) { UserLoyalty::STANDARD_POINT - limit_point_to_reach_standard }

      subject do
        user_loyalty.receive_point(point)
      end

      context 'after process then accumulate_point less than standard point' do
        let(:point) { limit_point_to_reach_standard - 1 }

        it 'should not update current_point' do
          expect do
            subject
          end.not_to change(user_loyalty, :current_point)
        end
      end

      context 'after process then accumulate_point equal standard point' do
        let(:point) { limit_point_to_reach_standard }

        it 'should add standard point to current_point' do
          expect do
            subject
          end.to change(
            user_loyalty,
            :current_point
          ).from(current_point).to(current_point + UserLoyalty::STANDARD_POINT)
        end
      end

      context 'after process then accumulate_point bigger than standard point' do
        let(:point) { limit_point_to_reach_standard + 2.5 + (2 * UserLoyalty::STANDARD_POINT) }

        it 'should add standard point to current_point' do
          expect do
            subject
          end.to change(
            user_loyalty,
            :current_point
          ).from(current_point).to(current_point + (3 * UserLoyalty::STANDARD_POINT))
        end

        it 'should keep the remain record on accumulate_point' do
          expect do
            subject
          end.to change(user_loyalty, :accumulate_point).from(accumulate_point).to(2.5)
        end

        it 'record user point history' do
          subject

          expect(UserPointHistory.count).to eq(1)

          expect(user_loyalty.user.point_histories.first.point).to eq(3 * UserLoyalty::STANDARD_POINT)
        end
      end
    end

    context '#reset_point' do
      let!(:user_loyalty_one) { create(:user_loyalty, current_point: 100, user: user_one) }
      let!(:user_loyalty_two) { create(:user_loyalty, current_point: 200, user: user_two) }
      let!(:user_loyalty_three) { create(:user_loyalty, current_point: 300, user: user_three) }

      it 'should reset all user_loyalty current point to 0' do
        described_class.reset_point

        expect(user_loyalty_one.reload.current_point.zero?).to be_truthy
        expect(user_loyalty_two.reload.current_point.zero?).to be_truthy
        expect(user_loyalty_three.reload.current_point.zero?).to be_truthy
      end
    end

    context '#reset_tier' do
      let!(:user_loyalty_one) { create(:user_loyalty, user: user_one) }
      let!(:user_loyalty_two) { create(:user_loyalty, user: user_two) }
      let!(:user_loyalty_three) { create(:user_loyalty, user: user_three) }

      before do
        cycle_one_created_at = Time.now - 1.years
        cycle_two_created_at = Time.now - 2.years
        cycle_three_created_at = Time.now - 3.years

        # user one point histories
        # last 3 cycle
        user_one.point_histories.create(point: 3000, created_at: cycle_three_created_at)
        user_one.point_histories.create(point: 2000, created_at: cycle_three_created_at)

        # last 2 cycle
        user_one.point_histories.create(point: 500, created_at: cycle_two_created_at)
        user_one.point_histories.create(point: 300, created_at: cycle_two_created_at)
        user_one.point_histories.create(point: 200, created_at: cycle_two_created_at)

        # last 1 cycle
        user_one.point_histories.create(point: 300, created_at: cycle_one_created_at)
        user_one.point_histories.create(point: 300, created_at: cycle_one_created_at)

        # user two point histories
        # last 2 cycle
        user_two.point_histories.create(point: 500, created_at: cycle_two_created_at)
        user_two.point_histories.create(point: 300, created_at: cycle_two_created_at)
        user_two.point_histories.create(point: 200, created_at: cycle_two_created_at)

        # last 1 cycle
        user_two.point_histories.create(point: 3000, created_at: cycle_one_created_at)
        user_two.point_histories.create(point: 2000, created_at: cycle_one_created_at)

        # user three point histories
        # last 1 cycle
        user_three.point_histories.create(point: 100, created_at: cycle_one_created_at)
        user_three.point_histories.create(point: 300, created_at: cycle_one_created_at)
        user_three.point_histories.create(point: 300, created_at: cycle_one_created_at)
      end

      it 'should reset tier for all user' do
        described_class.reset_tier

        expect(user_loyalty_one.reload.tier_gold?).to be_truthy
        expect(user_loyalty_two.reload.tier_platinum?).to be_truthy
        expect(user_loyalty_three.reload.tier_standard?).to be_truthy
      end
    end
  end
end
