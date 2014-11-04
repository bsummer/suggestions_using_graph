class FollowsController < ApplicationController
  respond_to :json

  def show
    user = User.find params[:id].to_i
    following = user.following
    r_hash = recommendation_to_hash(following)
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