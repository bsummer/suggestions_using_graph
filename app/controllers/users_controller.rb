class UsersController < ApplicationController
  def index
    @users = [] #User.all
  end

  def show
    @user = User.find params[:id].to_i
    @followers = @user.followers
    @following = @user.following
    @recommended = @user.recommended
  end

  def follow
    current_user.follows User.find(params[:id].to_i)
    redirect_to :controller => 'users', :action => :show, :id => current_user.account_id
  end

  def recommendations
    user = User.find params[:id].to_i
    recommended = user.recommended
    r_hash = recommendation_to_hash(recommended)
    render json: {users: r_hash}
  end

  def recommendation_to_hash(recommendations)
    recommendations.map do |recommendation|
      r = recommendation.to_hash
      r['outfit_image'] = recommendation.get_last_outfit_image_url
      r
    end
  end
end
