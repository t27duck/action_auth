# frozen_string_literal: true

require "action_auth/version"
require "action_auth/action_resolver"
require "action_auth/authorizer"
require "action_auth/config"
require "action_auth/config_parser"
require "action_auth/guest_user"
require "action_auth/role_chain_resolver"
require "action_auth/utilities"
require "action_auth/rails_controller"

module ActionAuth
  class Error < StandardError; end
  class ConfigParseError < StandardError; end
  class InvalidAuthorizeCall < StandardError; end
  class InvalidObjectError < StandardError; end
  class UserNotAuthorized < StandardError; end
end
