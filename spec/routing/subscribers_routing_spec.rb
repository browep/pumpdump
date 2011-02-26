require "spec_helper"

describe SubscribersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/subscribers" }.should route_to(:controller => "subscribers", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/subscribers/new" }.should route_to(:controller => "subscribers", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/subscribers/1" }.should route_to(:controller => "subscribers", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/subscribers/1/edit" }.should route_to(:controller => "subscribers", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/subscribers" }.should route_to(:controller => "subscribers", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/subscribers/1" }.should route_to(:controller => "subscribers", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/subscribers/1" }.should route_to(:controller => "subscribers", :action => "destroy", :id => "1")
    end

  end
end
