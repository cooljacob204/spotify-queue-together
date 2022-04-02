class SessionsController < ApplicationController
  def index
    @auth_query = {
      client_id: ENV.fetch('CLIENT_ID'),
      scope: 'user-read-private user-read-email streaming app-remote-control user-read-currently-playing',
      redirect_uri: ENV.fetch('REDIRECT_URI'),
      response_type: 'code'
    }
  end

  def callback
    token = SpotifyAdapters::ClientToken.generate(params[:code])
    token.session = session
    token.save_to_session!

    render json: { token: }
  end
end
