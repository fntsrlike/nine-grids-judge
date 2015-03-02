require 'test_helper'

class JudgementsControllerTest < ActionController::TestCase
  setup do
    @judgement = judgements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:judgements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create judgement" do
    assert_difference('Judgement.count') do
      post :create, judgement: { answer_id: @judgement.answer_id, content: @judgement.content, user_id: @judgement.user_id }
    end

    assert_redirected_to judgement_path(assigns(:judgement))
  end

  test "should show judgement" do
    get :show, id: @judgement
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @judgement
    assert_response :success
  end

  test "should update judgement" do
    patch :update, id: @judgement, judgement: { answer_id: @judgement.answer_id, content: @judgement.content, user_id: @judgement.user_id }
    assert_redirected_to judgement_path(assigns(:judgement))
  end

  test "should destroy judgement" do
    assert_difference('Judgement.count', -1) do
      delete :destroy, id: @judgement
    end

    assert_redirected_to judgements_path
  end
end
