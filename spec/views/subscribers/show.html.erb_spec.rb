require 'spec_helper'

describe "subscribers/show.html.erb" do
  before(:each) do
    @subscriber = assign(:subscriber, stub_model(Subscriber))
  end

  it "renders attributes in <p>" do
    render
  end
end
