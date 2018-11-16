# frozen_string_literal: true

module ActionAuth
  class Authorizer
    def initialize(user:, category:, action:, object: nil)
      @user = Utilities.validate_user(user)
      @action = action
      @category_config = Config.config[category.to_sym]
      @object = object

      raise InvalidAuthorizeCall, "Unknown category '#{category}'" if @category_config.nil?
    end

    def authorized?
      resolvers = role_resolvers

      return false if resolvers.empty?

      resolvers.each do |resolver|
        result = resolver.resolve(user: @user, object: @object)
        return true if result
      end

      false
    end

    private

    def role_resolvers
      roles = RoleChainResolver.new(@user.role_symbols).resolve

      resolvers = roles.map do |role|
        actions = @category_config[role]
        actions[@action.to_sym] if actions
      end.flatten

      resolvers.delete_if(&:nil?)
      resolvers
    end
  end
end
