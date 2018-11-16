# frozen_string_literal: true

module ActionAuth
  module RailsController
    def self.included(base)
      base.extend ClassMethods
    end

    def action_auth_user
      user = send(ActionAuth::Config.current_user_method)
      user || ActionAuth::GuestUser.new
    end

    module ClassMethods
      def authorize_on(*actions, with_object: nil)
        actions.each do |action|
          method_name = "authorize_on_#{action}_#{Time.now.to_i}".to_sym
          build_authorize_method(method_name, with_object: with_object)
          before_action method_name, only: action.to_sym
        end
      end

      def build_authorize_method(method_name, with_object:)
        define_method(method_name) do
          obj = instance_variable_get("@#{with_object}") if with_object
          auth = ActionAuth::Authorizer.new(
            user: action_auth_user,
            category: controller_path.tr("\/", "_"),
            action: action_name,
            object: obj
          )

          raise ActionAuth::UserNotAuthorized unless auth.authorized?
        end
      end
    end
  end
end
