# frozen_string_literal: true

module ActionAuth
  class ActionResolver
    attr_reader :strategy

    def initialize(strat)
      unless strat.nil? || strat.respond_to?(:call)
        raise ArgumentErrr, "Resolve strategry should be nil or a callable object"
      end

      @strategy = strat
    end

    def resolve(user:, object: nil)
      return true if @strategy.nil?

      if @strategy.arity == 1
        @strategry.call(user)
      else
        @strategry.call(user, object)
      end
    end
  end
end
