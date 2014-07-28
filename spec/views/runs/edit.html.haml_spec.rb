require 'rails_helper'

RSpec.describe "runs/edit", :type => :view do
  before(:each) do
    @run = assign(:run, Run.create!())
  end

  it "renders the edit run form" do
    render

    assert_select "form[action=?][method=?]", run_path(@run), "post" do
    end
  end
end
