class ApplicationController < ActionController::Base
  before_action :authorize

  def authorize
    redirect_to :login_index unless session[:auth]
  end
end
