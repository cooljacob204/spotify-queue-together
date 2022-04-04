module SpotifyAdapters
  class Client
    def initialize(token)
      @token = token
    end

    def get(path, query = nil, headers = {})
      HTTPClient.new.get(path, query, headers.merge(authorization_header))
    end

    def post(path, body = nil, headers = {})
      HTTPClient.new.post(path, body, headers.merge(authorization_header))
    end

    def put(path, body = nil, headers = {})
      HTTPClient.new.put(path, body, headers.merge(authorization_header))
    end

    private

    def authorization_header
      {
        Authorization: "Bearer #{token.access_token}"
      }
    end

    def token
      @token.tap do |token|
        token.refresh! if token.expired?
      end
    end
  end
end
