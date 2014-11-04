class FollowingController < ApplicationController
  def index
    @users = current_user.following
  end

  def follow
    current_user.follows User.find(params[:id].to_i)
    redirect_to :controller => 'following', :action => :index
  end

  def unfollow
    current_user.unfollows User.find(params[:id].to_i)
    redirect_to :controller => 'following', :action => :index
  end

  def suggest
    @users = current_user.recommended

    render :index
  end
end