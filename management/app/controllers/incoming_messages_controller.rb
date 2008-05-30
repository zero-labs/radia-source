class IncomingMessagesController < ApplicationController
  before_filter :login_required
  before_filter :find_user_and_mailbox_from_params
  
  # GET /users/:user_id/mailbox/incoming
  # GET /users/:user_id/mailbox/incoming.:format
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @mailbox.mail.to_xml }
    end
  end
  
  # GET /users/:user_id/mailbox/incoming/:id
  # GET /users/:user_id/mailbox/incoming/:id.:format
  def show
    @message = Message.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @message.to_xml }
    end
  end
  
  # DELETE /users/:user_id/mailbox/incoming/:id
  # DELETE /users/:user_id/mailbox/incoming/:id.:format
  def destroy
    @message = Message.find(params[:id])
    
    respond_to do |format|
      flash[:notice] = "Message moved to trash"
      format.html { redirect_to user_mailbox_incoming_path(@user) }
      format.xml { head :ok }
    end
  end
  
  protected
  
  def find_user_and_mailbox_from_params
    @user = User.find(params[:user_id])
    @mailbox = @user.mailbox[:inbox]
  end
end
