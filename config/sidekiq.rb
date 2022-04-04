Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://localhost:6380/1' } }
  config.average_scheduled_poll_interval = 1
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('SIDEKIQ_REDIS_URL') { 'redis://localhost:6380/1' } }
end
