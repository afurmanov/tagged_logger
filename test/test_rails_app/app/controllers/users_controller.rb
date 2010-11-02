class UsersController < ApplicationController
  def index
    logger.debug "listing users..."
    @users = User.everyone
    UserMailer.index_email.deliver
    render
  end
end
