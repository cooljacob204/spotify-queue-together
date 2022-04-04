class RoomsController < ApplicationController
  before_action :authorize, only: :create

  def index; end

  def create
    room = Room.create(spotify_host_token: SpotifyAdapters::ClientToken.token_from_session(session))

    session[:room_id] = room.id
    session[:user_id] = room.host_id

    redirect_to search_path
  end

  private

  def authorize
    token = session[:auth] && SpotifyAdapters::ClientToken.token_from_session(session)
    token.refresh! if token&.expired?

    redirect_to :login_index unless token
  end
end
