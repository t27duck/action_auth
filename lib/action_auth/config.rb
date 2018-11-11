# frozen_string_literal: true

module ActionAuth
  class Config
    def self.config
      @config ||= {}
    end

    def self.chains
      @chains ||= {}
    end

    def self.parse(data)
      parser = ConfigParser.parse(data)
      @config = parser.config
      @chains = parser.chains
    end
  end
end
