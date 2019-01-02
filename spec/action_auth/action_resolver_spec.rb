# frozen_string_literal: true

RSpec.describe ActionAuth::ActionResolver do
  include_context "config examples"

  describe "#initialize" do
    it "accepts nil for the strategy" do
      subject = ActionAuth::ActionResolver.new(nil)
      expect(subject.strategy).to eq(nil)
    end

    it "accepts a callable object for the strategy" do
      subject = ActionAuth::ActionResolver.new(resolve_option_user_arg)
      expect(subject.strategy).to eq(resolve_option_user_arg)
    end

    it "rejects a non-nil or non-callable object as the strategy" do
      expect do
        ActionAuth::ActionResolver.new(:foo)
      end.to raise_error(ArgumentError, /nil or a callable object/)
    end
  end

  describe "#resolve" do
    context "with nil strategy" do
      it "always resolves to true" do
        subject = ActionAuth::ActionResolver.new(nil)
        expect(subject.resolve(user: user)).to be_truthy
      end
    end

    context "with a callable object as the strategy" do
      context "with an arity of 1" do
        it "calls the resolution and passes the user" do
          subject = ActionAuth::ActionResolver.new(resolve_option_user_arg)
          expect(resolve_option_user_arg).to receive(:call).with(user).exactly(1).and_call_original
          expect(subject.resolve(user: user)).to be_truthy
        end
      end

      context "with an arity of 2" do
        it "calls the resolution and passes the user and object" do
          subject = ActionAuth::ActionResolver.new(resolve_option_object_arg)
          expect(resolve_option_object_arg).to receive(:call).with(user, nil).exactly(1).and_call_original
          expect(subject.resolve(user: user)).to be_truthy

          object = 1
          expect(resolve_option_object_arg).to receive(:call).with(user, object).exactly(1).and_call_original
          expect(subject.resolve(user: user, object: object)).to be_truthy
        end
      end
    end
  end
end
