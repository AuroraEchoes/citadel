require 'steam_id'

module UsersHelper
  include UsersPermissions
  include Features

  def current_user?
    current_user == @user
  end
end
