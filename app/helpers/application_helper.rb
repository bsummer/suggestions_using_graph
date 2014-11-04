module ApplicationHelper
  def show_follow_link(account_id)
    return false if current_user.account_id == account_id
    return false if current_user.following?(account_id)
    true
  end
end
