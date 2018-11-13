# frozen_string_literal: true

module ActionAuth
  class Resolver
    def resolve(category:, action:, user:, object: nil)
      @category_config = Config.config[category]
      return false if @category_config.nil?

      @role_chain = []
      resolve_role_chain(roles: user.role_symbols)
      resolve_strategies(action: action, user: user, object: object)
    end

    private

    def resolve_role_chain(roles:)
      roles_to_walk = @role_chain - roles
      return if roles_to_walk.empty?

      @role_chain += roles_to_walk
      roles_to_walk.each do |new_base|
        current_chain = Config.chains[new_base]
        resolve_role_chain(roles: current_chain) unless current_chain.nil?
      end
    end

    def resolve_strategies(action:, user:, object: nil)
      @role_chain.each do |role|
        strategies = strategries_for_role_and_action(role: role, action: action)
        Array(strategies).each do |resolve_strategy|
          return true if resolve_strategy.resolve(user: user, object: object)
        end
      end

      false
    end

    def strategries_for_role_and_action(role:, action:)
      role_config = @category_config[role]
      return nil if role_config.nil?

      role_config[action]
    end
  end
end
