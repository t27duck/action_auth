# frozen_string_literal: true

module ActionAuth
  class GuestUser
    attr_accessor :role_symbols

    def initalize
      @role_symbols = [:guest]
    end
  end
end
