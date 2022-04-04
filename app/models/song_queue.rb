class SongQueue
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def add_to_queue(song)
    redis.lpush(queue_key, song.to_json)
    redis.expire(queue_key, queue_expire_time)
  end

  def add_to_front_of_queue(song)
    redis.rpush(queue_key, song.to_json)
    redis.expire(queue_key, queue_expire_time)
  end

  def pop
    redis.rpop(queue_key).then { |raw_song| JSON.parse(raw_song) if raw_song }
  end

  def length
    redis.llen(queue_key)
  end

  def empty?
    length.zero?
  end

  def queue_key
    "#{song_queue_prefix}:#{id}"
  end

  def clear
    redis.del(queue_key)
  end

  def list
    redis.lrange(queue_key, 0, -1).map { |song| JSON.parse(song) }
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
