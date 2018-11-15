# frozen_string_literal: true

module ActionAuth
  class RoleChainResolver
    def initialize(base_roles)
      @base_roles = Array(base_roles)
      @full_chain = []
    end

    def resolve
      walk_chain(@base_roles)
      @full_chain
    end

    private

    def walk_chain(roles_to_walk)
      roles_to_walk.each do |new_base|
        next if @full_chain.include?(new_base)

        @full_chain << new_base
        current_chain = Config.chains[new_base]
        walk_chain(current_chain) unless current_chain.nil?
      end
    end

    def resolve_chain(roles:)
      roles_to_walk = @full_chain - roles
      return if roles_to_walk.empty?

      @full_chain += roles_to_walk
      walk_chain(roles_to_walk)
    end
  end
end
