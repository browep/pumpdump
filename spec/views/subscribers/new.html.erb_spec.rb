require 'spec_helper'

describe "subscribers/new.html.erb" do
  before(:each) do
    assign(:subscriber, stub_model(Subscriber).as_new_record)
  end

  it "renders new subscriber form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => subscribers_path, :method => "post" do
    end
  end
end
