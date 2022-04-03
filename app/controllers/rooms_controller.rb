class RoomsController < ApplicationController
  skip_before_action :authorize, except: [:create]

  def index; end

  def create
    room = Room.create
    room.host_token = SpotifyAdapters::ClientToken.token_from_session(session)

    redirect_to room_path(room.id)
  end

  def show
    render html: Room.new(params[:id]).host_token.to_s
  end
end
