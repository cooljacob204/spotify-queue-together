require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    before { get login_index_path }

    it "is a success" do
      expect(response).to have_http_status(:ok)
    end

    it "renders 'index' template" do
      expect(response).to render_template('index')
    end
  end
end
