# frozen_string_literal: true

require "rack/test"
require "rails_setup"

require "pry"

RSpec.describe "Rails integration" do
  include Rack::Test::Methods
  include_context "config examples"

  def app
    Rails.application
  end

  before do
    ActionAuth::Config.parse(admin_mod_reg_and_two_specials)
  end

  context "non-namespaced controller" do
    class PostsController < ApplicationController
      before_action :set_post, only: :update
      authorize_on :index
      authorize_on :edit, :update, with_object: :post

      def index
        render inline: "It worked"
      end

      def edit
        render inline: "This shouldn't work"
      end

      def update
        render inline: "Update worked"
      end

      private

      def set_post
        @post = Class.new
      end
    end

    it "returns 500 if object is expected, but not provided" do
      get "/posts/1/edit"
      expect(last_response.status).to eq(500)
    end

    it "uses the object that was passed through the controller" do
      stub_current_user(roles: [:regular])
      patch "/posts/1/"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Update worked")
    end

    it "blocks a user who does not have access" do
      get "/posts"
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Not authorized")
    end

    it "allows a user who has access" do
      stub_current_user(roles: [:admin])
      get "/posts"
      expect(last_response).to be_ok
      expect(last_response.body).to eq("It worked")
    end
  end

  context "namespaced controller" do
    module Admin
      class PostsController < ApplicationController
        authorize_on :index

        def index
          render inline: "It worked"
        end
      end
    end

    it "blocks a user who does not have access" do
      get "/admin/posts"
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Not authorized")
    end

    it "allows a user who has access" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(SpecUser.new(roles: [:admin]))
      get "/admin/posts"
      expect(last_response).to be_ok
      expect(last_response.body).to eq("It worked")
    end
  end
end
