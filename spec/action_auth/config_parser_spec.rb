# frozen_string_literal: true

RSpec.describe ActionAuth::ConfigParser do
  include_context "config examples"

  describe "parsing input (.parse)" do
    it "returns a hash of parsed configuration" do
      parser = ActionAuth::ConfigParser.parse(single_action_for_category)
      expect(parser).to be_a(ActionAuth::ConfigParser)
      expect(parser.config).to be_a(Hash)
      expect(parser.chains).to be_a(Hash)
    end

    describe "#role" do
      it "requires a block" do
        expect do
          ActionAuth::ConfigParser.parse(no_block_for_role)
        end.to raise_error(ActionAuth::ConfigParseError, /passed a block/)
      end

      describe "#category" do
        it "requires an action" do
          expect do
            ActionAuth::ConfigParser.parse(no_actions_for_category)
          end.to raise_error(ActionAuth::ConfigParseError, /at least one action/)
        end

        it "stores a single action" do
          config = ActionAuth::ConfigParser.parse(single_action_for_category).config
          expect(config[:posts][:admin]).to have_key(:index)
        end

        it "stores an array of actions" do
          config = ActionAuth::ConfigParser.parse(multiple_actions_for_category).config
          expect(config[:posts][:admin]).to have_key(:index)
          expect(config[:posts][:admin]).to have_key(:show)
        end

        it "stores a resolver for the resolve option if not passed" do
          config = ActionAuth::ConfigParser.parse(multiple_actions_for_category_no_resolve).config
          expect(config[:posts][:admin][:index]).to be_an(Array)
          expect(config[:posts][:admin][:index][0]).to be_an(ActionAuth::ActionResolver)
          expect(config[:posts][:admin][:index][0].strategy).to be_nil
        end

        it "stores a resolver for the resolve option" do
          config = ActionAuth::ConfigParser.parse(multiple_actions_for_category).config
          expect(config[:posts][:admin][:index]).to be_an(Array)
          expect(config[:posts][:admin][:index][0]).to be_an(ActionAuth::ActionResolver)
          expect(config[:posts][:admin][:index][0].strategy).to be_a(Proc)
        end

        it "stores multiple calls to the same action's resolve options" do
          config = ActionAuth::ConfigParser.parse(multiple_calls_to_same_category).config
          expect(config[:posts][:admin][:index].size).to eq(2)
          expect(config[:posts][:admin][:index][0]).to be_an(ActionAuth::ActionResolver)
          expect(config[:posts][:admin][:index][0].strategy).to be_nil
          expect(config[:posts][:admin][:index][1]).to be_an(ActionAuth::ActionResolver)
          expect(config[:posts][:admin][:index][1].strategy).to be_a(Proc)
        end
      end

      describe "#includes" do
        it "yields an empty chain no includes are invoked" do
          chains = ActionAuth::ConfigParser.parse(multiple_actions_for_category).chains
          expect(chains).to be_a(Hash)
          expect(chains).to be_empty
        end

        it "includes an entry for every role that has an includes" do
          chains = ActionAuth::ConfigParser.parse(admin_includes_user).chains
          expect(chains[:admin]).to include(:regular)
          expect(chains[:regular]).to be_nil
        end

        it "does NOT follow the includes chain through all roles" do
          chains = ActionAuth::ConfigParser.parse(admin_mod_user_chain).chains
          expect(chains[:admin]).to include(:mod)
          expect(chains[:admin]).to_not include(:regular)
          expect(chains[:mod]).to include(:regular)
          expect(chains[:regular]).to be_nil
        end
      end
    end
  end
end
