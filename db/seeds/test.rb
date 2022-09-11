require_relative '../helpers/say_with_time'

say_with_time 'Loading seeds file' do
  say_with_time 'Issue Rewards' do
    rewards = %w[free_coffee 5_percentage_cash_rebate free_movie_ticket airport_lounge_access]

    rewards.each do |name|
      Reward.find_or_create_by(name:)
    end
  end
end
