# frozen_string_literal: true

module ActionAuth
  class ActionResolver
    attr_reader :strategy

    def initialize(strat)
      unless strat.nil? || strat.respond_to?(:call)
        raise ArgumentError, "Resolve strategry should be nil or a callable object"
      end

      @strategy = strat
    end

    def resolve(user:, object: nil)
      return true if @strategy.nil?
      return @strategy.call(user) if @strategy.arity == 1

      @strategy.call(user, object)
    end
  end
end
