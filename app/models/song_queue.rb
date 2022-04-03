class SongQueue
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def add_to_queue(song)
    redis.lpush("#{song_queue_prefix}:#{id}", song.to_json)
    redis.expire("#{song_queue_prefix}:#{id}", queue_expire_time)
  end

  def pop_song
    JSON.parse(redis.rpop("#{song_queue_prefix}:#{id}"))
  end

  private

  def song_queue_prefix
    'song_queue'
  end

  def queue_expire_time
    60 * 60 * 6
  end

  def redis
    REDIS_DB
  end
end
