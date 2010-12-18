require 'test_helper'

class BadSymbolsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => BadSymbols.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    BadSymbols.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    BadSymbols.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to bad_symbols_url(assigns(:bad_symbols))
  end
  
  def test_edit
    get :edit, :id => BadSymbols.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    BadSymbols.any_instance.stubs(:valid?).returns(false)
    put :update, :id => BadSymbols.first
    assert_template 'edit'
  end
  
  def test_update_valid
    BadSymbols.any_instance.stubs(:valid?).returns(true)
    put :update, :id => BadSymbols.first
    assert_redirected_to bad_symbols_url(assigns(:bad_symbols))
  end
  
  def test_destroy
    bad_symbols = BadSymbols.first
    delete :destroy, :id => bad_symbols
    assert_redirected_to bad_symbols_url
    assert !BadSymbols.exists?(bad_symbols.id)
  end
end
