module SpotifyAdapters
  class ClientToken
    attr_reader :access_token, :expires_at, :refresh_token, :scope, :token_type
    attr_accessor :session

    class << self
      def generate(code)
        token_hash = request(code)
        new(
          token_hash['access_token'],
          (Time.now + token_hash['expires_in']).to_i,
          token_hash['refresh_token'],
          token_hash['scope'],
          token_hash['token_type']
        )
      end

      def token_from_session(session)
        raise ArgumentError, 'No token found' unless session[:auth].present?

        new(
          session[:auth]['access_token'],
          session[:auth]['expires_at'],
          session[:auth]['refresh_token'],
          session[:auth]['scope'],
          session[:auth]['token_type']
        ).tap { |token| token.session = session }
      end

      def request(code)
        body = { redirect_uri: ENV.fetch('REDIRECT_URI'), grant_type: 'authorization_code', code: }

        headers = {
          Authorization: "Basic #{Base64.strict_encode64("#{ENV.fetch('CLIENT_ID')}:#{ENV.fetch('CLIENT_SECRET')}")}"
        }

        resp = HTTPClient.new.post('https://accounts.spotify.com/api/token', body, headers)

        raise "Spotify returned an error: #{resp.body}" unless resp.status == 200

        JSON.parse(resp.body)
      end
    end

    def initialize(access_token, expires_at, refresh_token, scope, token_type)
      @access_token = access_token
      @expires_at = expires_at
      @refresh_token = refresh_token
      @scope = scope
      @token_type = token_type
    end

    def save_to_session!
      session[:auth] = {
        access_token:,
        expires_at:,
        refresh_token:,
        scope:,
        token_type:
      }
    end

    def expired?
      Time.now.to_i > expires_at
    end

    def refresh!
      token_hash = refresh_request

      @access_token = token_hash['access_token']
      @expires_at = (Time.now + token_hash['expires_in']).to_i
      @refresh_token = token_hash['refresh_token']
      @scope = token_hash['scope']
      @token_type = token_hash['token_type']

      self
    end

    def refresh_and_save_to_session!
      refresh!
      save_to_session!
    end

    private

    def refresh_request
      body = { redirect_uri: ENV.fetch('REDIRECT_URI'), grant_type: 'refresh_token', refresh_token: }

      headers = {
        Authorization: "Basic #{Base64.strict_encode64("#{ENV.fetch('CLIENT_ID')}:#{ENV.fetch('CLIENT_SECRET')}")}"
      }

      resp = HTTPClient.new.post('https://accounts.spotify.com/api/token', body, headers)

      raise "Spotify returned an error: #{resp.body}" unless resp.status == 200

      JSON.parse(resp.body)
    end
  end
end
