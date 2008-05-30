class OutgoingMessagesController < ApplicationController
  before_filter :find_user_and_mailbox_from_params
  
  # GET /users/:user_id/mailbox/outgoing
  # GET /users/:user_id/mailbox/outgoing.:format
  def index
    
  end
  
  # GET /users/:user_id/mailbox/outgoing/:id
  # GET /users/:user_id/mailbox/outgoing/:id.:format
  def show
    
  end
  
  # DELETE /users/:user_id/mailbox/outgoing/:id
  # DELETE /users/:user_id/mailbox/outgoing/:id.:format
  def destroy
    
  end
  
  protected
  
  def find_user_and_mailbox_from_params
    @user = User.find(params[:user_id])
    @mailbox = @user.mailbox[:sent]
  end
end
