class Room
  attr_reader :id

  class << self
    def create
      new(Array.new(5) { [*'A'..'Z', *'0'..'9'].sample }.join)
    end
  end

  def initialize(id)
    @id = id
  end

  def save_to_redis
    redis.set("#{room_prefix}:#{id}", { host_token: host_token.to_hash }.to_json, ex: room_expire_time)
  end

  def host_token=(token)
    @host_token = token
    save_to_redis
  end

  def host_token
    @host_token ||= JSON.parse(redis.get("#{room_prefix}:#{id}")).fetch('host_token').then do |token_hash|
      SpotifyAdapters::ClientToken.new(
        token_hash['access_token'],
        token_hash['expires_at'],
        token_hash['refresh_token'],
        token_hash['scope'],
        token_hash['token_type']
      )
    end
  end

  private

  def room_prefix
    'room'
  end

  def room_queue_prefix
    'room_queue'
  end

  def room_expire_time
    60 * 60 * 6
  end

  def redis
    @redis ||= Redis.new(Rails.application.config_for(:database))
  end
end
