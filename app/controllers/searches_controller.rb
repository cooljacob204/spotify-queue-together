class SearchesController < ApplicationController
  before_action :validate_room_id

  def show; end

  private

  def validate_room_id
    redirect_to :rooms unless session[:room_id].present?
  end
end
