# frozen_string_literal: true

RSpec.describe ActionAuth::Utilities do
  include_context "config examples"

  describe ".validate_user" do
    it "allows for objects that respond to #role_symbols" do
      expect(ActionAuth::Utilities.validate_user(user)).to eq(user)
    end

    it "requires an object that respond to #role_symbols" do
      expect do
        ActionAuth::Utilities.validate_user(invalid_user)
      end.to raise_error(ActionAuth::InvalidObjectError, /must implement #role_symbols/)
    end
  end
end
