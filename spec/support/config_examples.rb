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

  let(:resolve_option) { ->(u) { u.pass } }
end
