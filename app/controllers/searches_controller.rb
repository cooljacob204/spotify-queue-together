class SearchesController < ApplicationController
  before_action :validate_room_id

  def create
    response =
      SpotifyAdapters::Client
        .new(Room.find_by_id(session[:room_id]).host_token)
        .get("https://api.spotify.com/v1/search?q=#{search_query}" )

    render json: JSON.parse(response.body), status: response.status
  end

  def show; end

  private

  def validate_room_id
    redirect_to :rooms unless session[:room_id].present?
  end

  def search_query
    "track:#{value}&type=track,artist,album&market=US"
  end

  def value
    params[:value]
  end

  def type
    params[:type]
  end

  def market
    params[:market]
  end
end
