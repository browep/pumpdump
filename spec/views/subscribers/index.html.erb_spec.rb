require 'spec_helper'

describe "subscribers/index.html.erb" do
  before(:each) do
    assign(:subscribers, [
      stub_model(Subscriber),
      stub_model(Subscriber)
    ])
  end

  it "renders a list of subscribers" do
    render
  end
end
