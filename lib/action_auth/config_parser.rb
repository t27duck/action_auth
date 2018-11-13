# frozen_string_literal: true

require "set"

module ActionAuth
  class ConfigParser
    attr_reader :config
    attr_reader :chains

    def self.parse(data)
      parser = new
      parser.instance_eval(data)
      parser
    end

    def initialize
      @config = {}
      @chains = {}
    end

    private

    def role(role_name, &block)
      raise ConfigParseError, "role must be passed a block" unless block_given?

      @current_role = role_name.to_sym
      yield block
    end

    def category(name, actions: [], resolve: nil)
      category_name = name.to_sym
      @config[category_name] ||= {}
      category_config = @config[category_name][@current_role] ||= {}
      raise ConfigParseError, "category must have at least one action" if actions.empty?

      Array(actions).each do |action|
        category_config[action.to_sym] ||= []
        category_config[action.to_sym] << ActionResolver.new(resolve)
      end
    end

    def includes(name)
      role_name = name.to_sym
      @chains[@current_role] ||= Set.new
      @chains[@current_role].add(role_name)
    end
  end
end
