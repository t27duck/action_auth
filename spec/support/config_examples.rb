# frozen_string_literal: true

RSpec.shared_context "config examples" do
  let(:no_block_for_role) { "role :some_role" }

  let(:no_actions_for_category) do
    <<~INPUT
      role :admin do
        category :posts
      end
    INPUT
  end

  let(:single_action_for_category_no_resolve) do
    <<~INPUT
      role :admin do
        category :posts, actions: :index
      end
    INPUT
  end

  let(:multiple_actions_for_category_no_resolve) do
    <<~INPUT
      role :admin do
        category :posts, actions: [:index, :show]
      end
    INPUT
  end

  let(:single_action_for_category) do
    <<~INPUT
      role :admin do
        category :posts, actions: :index, resolve: ->(u) { u.pass }
      end
    INPUT
  end

  let(:multiple_actions_for_category) do
    <<~INPUT
      role :admin do
        category :posts, actions: [:index, :show], resolve: ->(u) { u.pass }
      end
    INPUT
  end

  let(:multiple_calls_to_same_category) do
    <<~INPUT
      role :admin do
        category :posts, actions: [:index]
        category :posts, actions: [:index], resolve: ->(u) { u.pass }
      end
    INPUT
  end

  let(:admin_includes_user) do
    <<~INPUT
      role :admin do
        includes :regular
        category :posts, actions: [:index, :create]
      end

      role :regular do
        category :posts, actions: :index
        category :posts, actions: :create, resolve: ->(user) { user.pass }
      end
    INPUT
  end

  let(:admin_mod_user_chain) do
    <<~INPUT
      role :admin do
        includes :mod
        category :posts, actions: [:index, :create]
      end

      role :mod do
        includes :regular
        category :posts, actions: [:index, :create]
      end

      role :regular do
        category :posts, actions: :index
        category :posts, actions: :create, resolve: ->(user) { user.pass }
      end
    INPUT
  end

  let(:admin_mod_reg_and_two_specials) do
    <<~INPUT
      role :admin do
        includes :mod
        category :posts, actions: [:index, :create]
      end

      role :mod do
        includes :regular
        category :posts, actions: [:index, :create]
      end

      role :regular do
        category :posts, actions: :index
        category :posts, actions: :create, resolve: ->(user) { user.pass }
      end

      role :special do
        includes :regular
      end

      role :special2 do
        category :posts, actions: :index
      end
    INPUT
  end

  let(:invalid_admin_includes_itself) do
    <<~INPUT
      role :admin do
        includes :admin
        category :posts, actions: [:index, :create]
      end
    INPUT
  end

  let(:resolve_option_no_arg) { -> { true } }
  let(:resolve_option_user_arg) { ->(u) { u.pass } }
  let(:resolve_option_object_arg) { ->(u, o) { u.pass || o } }

  class SpecUser
    attr_reader :pass

    def initialize(pass = true)
      @pass = pass
    end
  end

  let(:user) { SpecUser.new }

  let(:user_no_pass) { SpecUser.new(false) }
end
