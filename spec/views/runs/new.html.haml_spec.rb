require 'rails_helper'

RSpec.describe "runs/new", :type => :view do
  before(:each) do
    assign(:run, Run.new())
  end

  it "renders new run form" do
    render

    assert_select "form[action=?][method=?]", runs_path, "post" do
    end
  end
end
