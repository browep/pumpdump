require 'spec_helper'

describe "subscribers/edit.html.erb" do
  before(:each) do
    @subscriber = assign(:subscriber, stub_model(Subscriber))
  end

  it "renders the edit subscriber form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => subscriber_path(@subscriber), :method => "post" do
    end
  end
end
