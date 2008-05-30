class MailboxesController < ApplicationController
  
  # GET /users/:user_id/mailbox
  def show
    @user = User.find(params[:user_id])
  end
  
end
