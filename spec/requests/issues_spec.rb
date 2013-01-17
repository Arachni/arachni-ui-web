require 'spec_helper'

describe "Issues" do
  describe "GET /issues" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get issues_path
      response.status.should be(200)
    end
  end
end
