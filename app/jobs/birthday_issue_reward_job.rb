class BirthdayIssueRewardJob < ApplicationJob
  # Set the Queue as Default
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    BirthdayIssueRewardJob.set(wait_until: user.birthday.at_beginning_of_month.next_year).perform_later(user_id)

    reward = Reward.find_by!(name: 'free_coffee')

    user_reward = user.user_rewards.create!(reward:)
    user_reward.is_birthday_reward = true

    user_reward.save!
  end
end
