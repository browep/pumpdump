require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Source.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Source.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Source.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to source_url(assigns(:source))
  end
  
  def test_edit
    get :edit, :id => Source.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Source.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Source.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Source.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Source.first
    assert_redirected_to source_url(assigns(:source))
  end
  
  def test_destroy
    source = Source.first
    delete :destroy, :id => source
    assert_redirected_to sources_url
    assert !Source.exists?(source.id)
  end
end
