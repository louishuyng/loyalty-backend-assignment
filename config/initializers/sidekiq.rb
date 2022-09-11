require 'sidekiq/web'
require 'sidekiq/cron/web'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL_CACHING", "redis://localhost:6379/0") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL_CACHING", "redis://localhost:6379/0") }
end

# Sidekiq sessions don't play well with Redis based sessions and Devise.
# See: https://github.com/redis-store/redis-rails/issues/34
# And: https://github.com/mperham/sidekiq/issues/2899
# And: https://github.com/mperham/sidekiq/wiki/Monitoring#sessions-being-lost
# Sidekiq::Web.set(:sessions, false)

# Back button
Sidekiq::Web.app_url = '/'

# --- Sidekiq cron ---
# Test here: https://crontab.guru/
hash = {
  'Expire point every year and calculated tier for all user' => {
    'class' => 'ExpirePointAndResetTierJob',
    'cron' => '0 0 1 1 *', # Run every year
  },
  'Process give bonus points for all user every quarter ' => {
    'class' => 'QuarterRewardBonusPointJob',
    'cron' => '0 0 1 */3 *', # Run every quarter
  },
}.freeze

# Load scheduled jobs unless in test environment
Sidekiq::Cron::Job.load_from_hash(hash) if !Rails.env.test? && !Rails.env.development?
