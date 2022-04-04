class RoomNextSongJob
  include Sidekiq::Job

  attr_reader :room

  def perform(room_id)
    @room = Room.new(room_id)
    return unless room.exists?

    currently_playing = room.host.currently_playing

    if currently_playing.nil? || currently_playing['progress_ms'] < 6000
      wait_for_song_end if currently_playing

      play_next_song
    else
      RoomNextSongJob.perform_in(
        ((currently_playing['item']['duration_ms'] - currently_playing['progress_ms']) / 1000.0) - 5,
        room_id
      )
    end
  end

  def play_next_song
    song = room.queue.pop

    if song
      play_song(song)
    else
      RoomNextSongJob.perform_in(1, room.id)
    end
  end

  def play_song(song)
    if room.host.play_song(song['uri']).status == 204
      RoomNextSongJob.perform_in((song['duration_ms'] / 1000.0) - 5, room.id)
    else
      room.queue.add_to_front_of_queue(song)
      RoomNextSongJob.perform_in(1, room.id)
    end
  end

  def wait_for_song_end
    currently_playing = room.host.currently_playing

    while currently_playing && currently_playing['progress_ms'].positive?
      if currently_playing['progress_ms'] > 1000
        sleep 1
      else
        sleep 0.2
      end

      currently_playing = room.host.currently_playing
    end
  end
end
