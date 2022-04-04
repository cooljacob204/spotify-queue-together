class Room
  attr_reader :id

  delegate :redis, :room_prefix, to: :class

  class << self
    def create(spotify_host_token:)
      new(Array.new(5) { [*'A'..'Z', *'0'..'9'].sample }.join)
        .tap do |room|
          room.update(
            {
              host_token: spotify_host_token.to_hash,
              started: false
            },
            {
              ex: room_expire_time
            }
          )
        end
    end

    def find_by_id(id)
      new(id)
    end

    def redis
      REDIS_DB
    end

    def room_prefix
      'room'
    end

    def room_expire_time
      60 * 60 * 6
    end
  end

  def initialize(id)
    @id = id
  end

  def update(params, redis_params = {})
    set_redis(from_redis.merge(params).to_json, redis_params)
  end

  def exists?
    redis.exists("#{room_prefix}:#{id}").positive?
  end

  def host_token
    host.token
  end

  def started
    from_redis[:started]
  end

  def queue
    @queue ||= SongQueue.new("room:#{id}")
  end

  def host
    @host ||= Host.new(
      from_redis.fetch('host_token').then do |token_hash|
        token_from_hash(token_hash).tap { |token| token.room = self }
      end
    )
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

    set_redis(started: true)
  end

  def add_user
    update(num_users: num_users + 1)
  end

  def num_users
    from_redis.fetch('num_users') || 0
  end

  def token_from_hash(hash)
    SpotifyAdapters::ClientToken.new(
      hash['access_token'],
      hash['expires_at'],
      hash['refresh_token'],
      hash['scope'],
      hash['token_type']
    )
  end

  def host_id
    1
  end

  private

  def room_queue_prefix
    'room_queue'
  end

  def room_expire_time
    60 * 60 * 6
  end

  def from_redis
    JSON.parse(redis.get(redis_key) || "\{\}")
  end

  def set_redis(value, redis_params = {})
    redis.set(redis_key, value, **redis_params)
  end

  def redis_key
    "#{self.class.room_prefix}:#{id}"
  end
end
