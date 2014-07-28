require 'rails_helper'

RSpec.describe "runs/show", :type => :view do
  before(:each) do
    @run = assign(:run, Run.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
