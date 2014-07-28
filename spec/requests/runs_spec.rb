require 'rails_helper'

RSpec.describe "Runs", :type => :request do
  describe "GET /runs" do
    it "works! (now write some real specs)" do
      get runs_path
      expect(response.status).to be(200)
    end
  end
end
