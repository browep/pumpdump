require 'spec_helper'

describe SubscribersController do

  def mock_subscriber(stubs={})
    (@mock_subscriber ||= mock_model(Subscriber).as_null_object).tap do |subscriber|
      subscriber.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all subscribers as @subscribers" do
      Subscriber.stub(:all) { [mock_subscriber] }
      get :index
      assigns(:subscribers).should eq([mock_subscriber])
    end
  end

  describe "GET show" do
    it "assigns the requested subscriber as @subscriber" do
      Subscriber.stub(:find).with("37") { mock_subscriber }
      get :show, :id => "37"
      assigns(:subscriber).should be(mock_subscriber)
    end
  end

  describe "GET new" do
    it "assigns a new subscriber as @subscriber" do
      Subscriber.stub(:new) { mock_subscriber }
      get :new
      assigns(:subscriber).should be(mock_subscriber)
    end
  end

  describe "GET edit" do
    it "assigns the requested subscriber as @subscriber" do
      Subscriber.stub(:find).with("37") { mock_subscriber }
      get :edit, :id => "37"
      assigns(:subscriber).should be(mock_subscriber)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created subscriber as @subscriber" do
        Subscriber.stub(:new).with({'these' => 'params'}) { mock_subscriber(:save => true) }
        post :create, :subscriber => {'these' => 'params'}
        assigns(:subscriber).should be(mock_subscriber)
      end

      it "redirects to the created subscriber" do
        Subscriber.stub(:new) { mock_subscriber(:save => true) }
        post :create, :subscriber => {}
        response.should redirect_to(subscriber_url(mock_subscriber))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved subscriber as @subscriber" do
        Subscriber.stub(:new).with({'these' => 'params'}) { mock_subscriber(:save => false) }
        post :create, :subscriber => {'these' => 'params'}
        assigns(:subscriber).should be(mock_subscriber)
      end

      it "re-renders the 'new' template" do
        Subscriber.stub(:new) { mock_subscriber(:save => false) }
        post :create, :subscriber => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested subscriber" do
        Subscriber.should_receive(:find).with("37") { mock_subscriber }
        mock_subscriber.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :subscriber => {'these' => 'params'}
      end

      it "assigns the requested subscriber as @subscriber" do
        Subscriber.stub(:find) { mock_subscriber(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:subscriber).should be(mock_subscriber)
      end

      it "redirects to the subscriber" do
        Subscriber.stub(:find) { mock_subscriber(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(subscriber_url(mock_subscriber))
      end
    end

    describe "with invalid params" do
      it "assigns the subscriber as @subscriber" do
        Subscriber.stub(:find) { mock_subscriber(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:subscriber).should be(mock_subscriber)
      end

      it "re-renders the 'edit' template" do
        Subscriber.stub(:find) { mock_subscriber(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested subscriber" do
      Subscriber.should_receive(:find).with("37") { mock_subscriber }
      mock_subscriber.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the subscribers list" do
      Subscriber.stub(:find) { mock_subscriber }
      delete :destroy, :id => "1"
      response.should redirect_to(subscribers_url)
    end
  end

end
