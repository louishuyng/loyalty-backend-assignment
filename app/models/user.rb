class User < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  has_many :user_rewards, dependent: :destroy
  has_many :rewards, through: :user_rewards

  has_many :transactions, dependent: :destroy
  has_many :point_histories, class_name: 'UserPointHistory', dependent: :destroy, foreign_key: :user_id

  has_one :loyalty, class_name: 'UserLoyalty', foreign_key: :user_id, inverse_of: :user, dependent: :destroy

  ################################ CALLBACK ################################
  after_create do
    create_loyalty
    issue_birthday_reward_later
  end

  ################################ SETTING ################################
  jsonb_accessor :reward_metadata,
    issued_five_percentage_cash_rebate: :boolean,
    issued_free_movie_ticket: :boolean,
    issued_gold_reward: :boolean

  ################################ VALIDATION ################################
  # TODO: Implement JWT and Hashing password
  validates :user_name, :password, presence: true

  ################################ METHODS ################################
  private

  def issue_birthday_reward_later
    if birthday_over_in_this_year?
      BirthdayIssueRewardJob.set(wait_until: birthday.at_beginning_of_month.next_year).perform_later(id)
    elsif birthday_in_current_month?
      BirthdayIssueRewardJob.perform_later(id)
    else
      BirthdayIssueRewardJob.set(wait_until: birthday.at_beginning_of_month).perform_later(id)
    end
  end

  def birthday_over_in_this_year?
    birthday.month < Time.now.month
  end

  def birthday_in_current_month?
    birthday.month == Time.now.month
  end
end
