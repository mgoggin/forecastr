require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "is expected to return HTTP success" do
      get "/"

      expect(response).to have_http_status(:success)
    end

    it "is expected to render the show template" do
      get "/"

      expect(response).to render_template("home/show")
    end
  end
end
