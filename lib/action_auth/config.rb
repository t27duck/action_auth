# frozen_string_literal: true

module ActionAuth
  class Config
    def self.config
      @config ||= {}
    end

    def self.chains
      @chains ||= {}
    end

    def self.read(path)
      parse(File.read(path))
    end

    def self.parse(data)
      parser = ConfigParser.parse(data)
      @config = parser.config
      @chains = parser.chains
    end

    def self.current_user_method
      @current_user_method ||= :current_user
    end

    def self.current_user_method=(method_name)
      @current_user_method = method_name.to_sym
    end
  end
end
