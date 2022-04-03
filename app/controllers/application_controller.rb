class ApplicationController < ActionController::Base
  before_action :authorize

  rescue_from SpotifyAdapters::ClientToken::RequestError do
    redirect_to :login_index
  end

  def authorize
    token = session[:auth] && SpotifyAdapters::ClientToken.token_from_session(session)
    token.refresh_and_save_to_session! if token&.expired?

    redirect_to :login_index unless token
  end
end
