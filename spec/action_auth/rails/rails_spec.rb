# frozen_string_literal: true

require "rack/test"
require "rails_setup"

require "pry"

RSpec.describe "Rails integration" do
  include Rack::Test::Methods

  let(:spec_current_user) { SpecUser.new }

  def app
    Rails.application
  end

  before do
    config = <<~STR
      role :admin do
        category :posts, actions: [:index, :create, :new, :destroy]
      end
    STR
    ActionAuth::Config.parse(config)
  end

  context "non-namespaced controller" do
    class PostsController < ApplicationController
      authorize_on :index

      def index
        render inline: "It worked"
      end
    end

    it "blocks a user who does not have access" do
      get "/posts"
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Not authorized")
    end

    it "allows a user who has access" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(SpecUser.new(roles: [:admin]))
      get "/posts"
      expect(last_response).to be_ok
      expect(last_response.body).to eq("It worked")
    end
  end
end
