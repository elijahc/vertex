require 'rails_helper'

RSpec.describe "runs/index", :type => :view do
  before(:each) do
    assign(:runs, [
      Run.create!(),
      Run.create!()
    ])
  end

  it "renders a list of runs" do
    render
  end
end
