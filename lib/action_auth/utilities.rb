# frozen_string_literal: true

module ActionAuth
  class Utilities
    def self.validate_user(user)
      raise InvalidObjectError, "User object must implement #role_symbols" unless user.respond_to?(:role_symbols)

      user
    end
  end
end
