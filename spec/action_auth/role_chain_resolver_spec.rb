# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActionAuth::RoleChainResolver do
  include_context "config examples"

  it "returns a hash of parsed configuration" do
    ActionAuth::Config.parse(admin_mod_user_chain)
    chain = ActionAuth::RoleChainResolver.new([:mod]).resolve
    puts chain.inspect
  end
end
