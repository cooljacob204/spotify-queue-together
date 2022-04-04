class QueuedSongsController < ApplicationController
  before_action :validate_room_id

  def create
    Room.new(session[:room_id]).queue_song(params.require(:song).permit!.to_h)

    head :created
  end

  private

  def validate_room_id
    render :no_content unless session[:room_id].present?
  end
end
