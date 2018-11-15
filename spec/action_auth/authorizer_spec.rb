# frozen_string_literal: true

RSpec.describe ActionAuth::Authorizer do
  include_context "config examples"

  describe "#authorized?" do
    it "requires a known category to be given" do
      ActionAuth::Config.parse(single_action_for_category_no_resolve)
      expect do
        ActionAuth::Authorizer.new(user: user, category: :does_not_exist, action: :foo)
      end.to raise_error(ActionAuth::InvalidAuthorizeCall, /Unknown category/)
    end

    it "disalows access if user has no roles matching category and action" do
      user.role_symbols = [:someting_else]
      subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :create)
      expect(subject.authorized?).to be_falsey
    end

    context "simple, direct access from role" do
      it "allows access to roles with access to the action" do
        ActionAuth::Config.parse(admin_user_separate)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :index)
        expect(subject.authorized?).to be_truthy

        user.role_symbols = [:regular]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :create)
        expect(subject.authorized?).to be_falsey
      end

      it "allows access if one role allows it" do
        ActionAuth::Config.parse(admin_user_separate)
        user.role_symbols = %i[regular admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :index)
        expect(subject.authorized?).to be_truthy
      end
    end

    context "role has multiple calls to category" do
      it "allows access to category defined multiple times" do
        ActionAuth::Config.parse(multiple_calls_to_same_category)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :show)
        expect(subject.authorized?).to be_truthy
      end

      it "allows access to action defined mutiple times for same category" do
        ActionAuth::Config.parse(multiple_calls_to_same_category)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :index)
        expect(subject.authorized?).to be_truthy
      end
    end

    context "one level deep simple chain" do
      it "allows access to actions at the top level" do
        ActionAuth::Config.parse(admin_includes_user)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :edit)
        expect(subject.authorized?).to be_truthy

        user.role_symbols = [:regular]
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :edit)
        expect(subject.authorized?).to be_falsey
      end

      it "allows access to actions down the user's chain" do
        ActionAuth::Config.parse(admin_includes_user)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy

        user.role_symbols = [:regular]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy
      end
    end

    context "two levels of role chains" do
      it "allows access to actions at the top level" do
        ActionAuth::Config.parse(admin_mod_user_chain)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :admins_only, action: :index)
        expect(subject.authorized?).to be_truthy

        user.role_symbols = [:mod]
        subject = ActionAuth::Authorizer.new(user: user, category: :reports, action: :index)
        expect(subject.authorized?).to be_truthy

        user.role_symbols = [:regular]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy
      end

      it "allows access to actions all the way to the bottom of the chain" do
        ActionAuth::Config.parse(admin_mod_user_chain)
        user.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy
      end

      it "allows access to user with overlapping roles" do
        ActionAuth::Config.parse(admin_mod_user_chain)
        user.role_symbols = %i[admin regular]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy
      end
    end

    context "multiple roles with their own chains" do
      it "allows access to actions if one role chain grants access" do
        ActionAuth::Config.parse(admin_mod_reg_and_two_specials)
        user.role_symbols = %i[special special2]
        subject = ActionAuth::Authorizer.new(user: user, category: :club, action: :show)
        expect(subject.authorized?).to be_truthy
      end

      it "allows access to actions if both chains grant access" do
        ActionAuth::Config.parse(admin_mod_reg_and_two_specials)
        user.role_symbols = %i[special mod]
        subject = ActionAuth::Authorizer.new(user: user, category: :profile, action: :show)
        expect(subject.authorized?).to be_truthy
      end
    end

    context "action definitions with a resolve strategy" do
      it "allows access if action has no resolve and a failing resolve" do
        ActionAuth::Config.parse(multiple_calls_to_same_category)
        user_no_pass.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user_no_pass, category: :posts, action: :index)
        expect(subject.authorized?).to be_truthy
      end

      it "disallows access if the resolve fails" do
        ActionAuth::Config.parse(single_action_for_category)
        user_no_pass.role_symbols = [:admin]
        subject = ActionAuth::Authorizer.new(user: user_no_pass, category: :posts, action: :index)
        expect(subject.authorized?).to be_falsey
      end

      it "allows acces when passing in an object to the resolve strategy and the stratgey returns true" do
        ActionAuth::Config.parse(single_action_for_category)
        user.role_symbols = [:admin]
        object = 3
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :index, object: object)
        expect(subject.authorized?).to be_truthy
      end

      it "disallows acces when passing in an object to the resolve strategy and the stratgey returns false" do
        ActionAuth::Config.parse(single_action_for_category)
        user.role_symbols = [:admin]
        object = 0
        subject = ActionAuth::Authorizer.new(user: user, category: :posts, action: :index, object: object)
        expect(subject.authorized?).to be_truthy
      end
    end
  end
end
