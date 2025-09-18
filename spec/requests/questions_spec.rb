require 'rails_helper'

RSpec.describe "Questions", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/questions/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /answer" do
    it "returns http success" do
      get "/questions/answer"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /previous" do
    it "returns http success" do
      get "/questions/previous"
      expect(response).to have_http_status(:success)
    end
  end

end
