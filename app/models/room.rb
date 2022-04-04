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

  def exists?
    redis.exists("#{room_prefix}:#{id}").positive?
  end

  def save_to_redis
    redis.set("#{room_prefix}:#{id}", { host_token: host_token.to_hash, started: }.to_json, ex: room_expire_time)
  end

  def host_token=(token)
    @host_token = token
    save_to_redis
  end

  def host_token
    redis_room_raw = redis.get("#{room_prefix}:#{id}")
    return unless redis_room_raw || @host_token

    @host_token ||= JSON.parse(redis.get("#{room_prefix}:#{id}")).fetch('host_token').then do |token_hash|
      token_from_hash(token_hash).tap { |token| token.room = self }
    end
  end

  def started=(started)
    @started = started
    save_to_redis
  end

  def started
    redis_room_raw = redis.get("#{room_prefix}:#{id}")
    return false unless redis_room_raw || @started

    @started ||= JSON.parse(redis.get("#{room_prefix}:#{id}")).fetch('started', false)
  end

  def queue
    @queue ||= SongQueue.new("room:#{id}")
  end

  def host
    @host ||= Host.new(host_token)
  end

  def queue_song(song)
    if started
      queue.add_to_queue(song)
    else
      play_song(song)
    end
  end

  def play_song(song)
    host.play_song(song['uri'])
    RoomNextSongJob.perform_in((song['duration_ms'] + 100) / 1000.0, id)
    self.started = true
  end

  private

  def token_from_hash(hash)
    SpotifyAdapters::ClientToken.new(
      hash['access_token'],
      hash['expires_at'],
      hash['refresh_token'],
      hash['scope'],
      hash['token_type']
    )
  end

  def room_prefix
    'room'
  end

  def room_expire_time
    60 * 60 * 6
  end

  def redis
    REDIS_DB
  end
end
