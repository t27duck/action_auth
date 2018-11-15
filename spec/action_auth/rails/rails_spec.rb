# frozen_string_literal: true

require "rack/test"
require "rails_setup"

RSpec.describe "Rails integration" do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  it "works as just a spec to see if the app mounted" do
    get "/orders"
    expect(last_response).to be_ok
    expect(last_response.body).to eq("It worked")
  end
end
