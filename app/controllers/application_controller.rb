class ApplicationController < ActionController::Base
  rescue_from SpotifyAdapters::ClientToken::RequestError do
    redirect_to :login_index
  end
end
