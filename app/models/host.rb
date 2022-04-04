class Host
  attr_reader :token

  def initialize(token)
    @token = token
  end

  def play_song(song_uri)
    url = 'https://api.spotify.com/v1/me/player/play'
    headers = { 'Content-Type' => 'application/json' }

    client.put(url, { uris: [song_uri] }.to_json, headers)
  end

  def queue_song(song_uri)
    url = 'https://api.spotify.com/v1/me/player/queue'
    headers = { 'Content-length' => 0 }

    client.post("#{url}?#{{ uri: song_uri }.to_query}", nil, headers)
  end

  def currently_playing
    url = 'https://api.spotify.com/v1/me/player/currently-playing'
    headers = { 'Content-Type' => 'application/json' }

    request = client.get(url, nil, headers)

    return nil if request.status == 204

    JSON.parse(request.body)
  end

  private

  def client
    @client ||= SpotifyAdapters::Client.new(token)
  end
end
