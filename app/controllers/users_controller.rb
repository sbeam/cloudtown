class UsersController < ApplicationController

  def create
    ActionMailer
  end

  def index
    @users = User.all
  end
end
