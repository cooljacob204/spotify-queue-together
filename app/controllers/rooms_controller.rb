class RoomsController < ApplicationController
  before_action :authorize, only: :create

  def index; end

  def create
    room = Room.create
    room.host_token = SpotifyAdapters::ClientToken.token_from_session(session)

    redirect_to room_path(room.id)
  end

  def show
    session[:room_id] = params[:id]

    render html: Room.new(params[:id]).host_token.to_s
  end

  private

  def authorize
    token = session[:auth] && SpotifyAdapters::ClientToken.token_from_session(session)
    token.refresh_and_save_to_session! if token&.expired?

    redirect_to :login_index unless token
  end
end
