# frozen_string_literal: true

RSpec.describe ActionAuth::Config do
  describe "parsing a file (.read)" do
    it "parses a configuration file" do
      ActionAuth::Config.read("spec/fixtures/example_config.rb")
      expect(ActionAuth::Config.config).to be_a(Hash)
      expect(ActionAuth::Config.chains).to be_a(Hash)
      expect(ActionAuth::Config.config[:posts][:admin]).to have_key(:index)
    end
  end
end
