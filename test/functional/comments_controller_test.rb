require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  def setup
    @resource = Factory :resource
    @user = Factory :user
    @parent = Factory :comment
  end

  test "should get new page" do
    get :new, :resource_id => @resource
    assert_redirected_to login_url
    
    login_as @user
    get :new, :resource_id => @resource
    assert_response :success, @response.body

    get :new, :resource_id => @resource, :parent_id => @parent
    assert_response :success, @response.body
  end

  test "should create comment" do
    post :create, :resource_id => @resource, :comment => {:content => 'content'}
    assert_redirected_to login_url

    login_as @user
    assert_difference "@resource.comments.count" do
      post :create, :resource_id => @resource, :comment => {:content => 'content'}
    end

    assert_difference "@resource.comments.count" do
      assert_difference "@parent.children.count" do
        post :create, :resource_id => @resource, :parent_id => @parent, :comment => {:content => 'content'}
      end
    end
  end

  test "should vote_up comment" do
    comment = Factory :comment

    put :vote_up, :id => comment
    assert_redirected_to login_url
    
    login_as @user
    assert_difference "comment.reload.up_votes_count" do
      put :vote_up, :id => comment
    end
    assert_redirected_to resource_path(comment.resource, :anchor => comment.anchor)
  end

  test "should unvote_up comment" do
    comment = Factory :comment
    @user.vote comment, :up

    delete :unvote_up, :id => comment
    assert_redirected_to login_url

    login_as @user
    assert_difference "comment.reload.up_votes_count", -1 do
      delete :unvote_up, :id => comment
    end
    assert_redirected_to resource_path(comment.resource, :anchor => comment.anchor)
  end
end
