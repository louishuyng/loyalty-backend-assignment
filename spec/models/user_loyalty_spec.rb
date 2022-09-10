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
    it { is_expected.to validate_presence_of(:current_point) }
    it { is_expected.to validate_presence_of(:accumulate_point) }
  end

  describe 'methods' do
    let(:accumulate_point) { 0 }
    let(:current_point) { 20 }

    let(:user) { create(:user) }
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
        let(:point) { limit_point_to_reach_standard + 2 }

        it 'should add standard point to current_point' do
          expect do
            subject
          end.to change(
            user_loyalty,
            :current_point
          ).from(current_point).to(current_point + UserLoyalty::STANDARD_POINT)
        end

        it 'should keep the remain record on accumulate_point' do
          expect do
            subject
          end.to change(user_loyalty, :accumulate_point).from(accumulate_point).to(2)
        end
      end
    end
  end
end