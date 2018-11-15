# frozen_string_literal: true

require "rails"
# require "active_model/railtie"
# require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":mommory:")
# ActiveRecord::Base.logger = Logger.new(STDOUT)

class TestApp < Rails::Application
  # secrets.secret_token    = "secret_token"
  # secrets.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
  Rails.logger = config.logger

  routes.draw do
    resources :orders
  end
end

class OrdersController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    render inline: "It worked"
  end
end
