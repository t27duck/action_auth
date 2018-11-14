# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActionAuth::RoleChainResolver do
  include_context "config examples"

  it "only includes itself if there is no chain" do
    ActionAuth::Config.parse(admin_mod_user_chain)
    chain = ActionAuth::RoleChainResolver.new(:regular).resolve
    expect(chain).to eq([:regular])

    ActionAuth::Config.parse(single_action_for_category)
    chain = ActionAuth::RoleChainResolver.new(:regular).resolve
    expect(chain).to eq([:regular])
  end

  it "lists chains one role deep" do
    ActionAuth::Config.parse(admin_mod_user_chain)
    chain = ActionAuth::RoleChainResolver.new(:mod).resolve
    expect(chain).to eq(%i[mod regular])
  end

  it "includes the chains of multiple roles passed in" do
    ActionAuth::Config.parse(admin_mod_user_chain)
    chain = ActionAuth::RoleChainResolver.new(%i[admin mod]).resolve
    expect(chain).to eq(%i[admin mod regular])

    chain = ActionAuth::RoleChainResolver.new(%i[mod regular]).resolve
    expect(chain).to eq(%i[mod regular])

    chain = ActionAuth::RoleChainResolver.new(%i[admin regular]).resolve
    expect(chain).to eq(%i[admin mod regular])

    ActionAuth::Config.parse(admin_mod_reg_and_two_specials)
    chain = ActionAuth::RoleChainResolver.new(%i[admin special]).resolve
    expect(chain).to eq(%i[admin mod regular special])

    ActionAuth::Config.parse(admin_mod_reg_and_two_specials)
    chain = ActionAuth::RoleChainResolver.new(%i[special special2]).resolve
    expect(chain).to eq(%i[special regular special2])
  end
end
