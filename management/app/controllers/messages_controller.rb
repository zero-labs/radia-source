class MessagesController < ApplicationController
  before_filter :login_required
  before_filter :check_creation_only_on_sent_mailbox, :only => [:new, :create]
  before_filter :find_user_and_mailbox_from_params
  
  # GET /users/:user_id/mailboxes/:mailbox_id/messages 
  # GET /users/:user_id/mailboxes/:mailbox_id/messages.:format
  def index
    @active = 'my_account' if @user == current_user
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @mailbox.mail.to_xml }
    end
  end
  
  # GET /users/:user_id/mailboxes/:mailbox_id/messages/:id
  # GET /users/:user_id/mailboxes/:mailbox_id/messages/:id.:format
  def show
    @mail = Mail.find_by_message_id(params[:id])
    @mail.mark_as_read
    @mail.save
    
    @message = @mail.message
    @active = 'my_account' if @user == current_user
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @message.to_xml }
    end
  end
  
  # GET /users/:user_id/mailboxes/:mailbox_id/messages/new
  def new
    @message = Message.new
  end
  
  # POST /users/:user_id/mailboxes/:mailbox_id/messages
  # POST /users/:user_id/mailboxes/:mailbox_id/messages.:format
  def create
    @user = current_user
    respond_to do |format|
      if @user.send_message(find_recipients_from_params, params[:message][:body], params[:message][:subject])
        format.html { redirect_to user_mailbox_messages_path(@user)}
      end
    end
      
  end
  
  # DELETE /users/:user_id/mailboxes/:mailbox_id/messages/:id
  # DELETE /users/:user_id/mailboxes/:mailbox_id/messages/:id.:format
  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    
    respond_to do |format|
      flash[:notice] = "Message moved to trash"
      format.html { redirect_to user_mailbox_messages_path(@user, :mailbox_id => :inbox) }
      format.xml { head :ok }
    end
  end
  
  # DELETE /users/:user_id/mailboxes/:mailbox_id/messages/empty
  # DELETE /users/:user_id/mailboxes/:mailbox_id/messages/empty.:format
  def empty
    # TODO
  end
  
  protected
  
  def active_nav
    @active = 'users'
  end
  
  def check_creation_only_on_sent_mailbox
    if params[:mailbox_id] != 'sent'
      flash[:error] = "Messages can only be added to the Sent mailbox"
      redirect_to root_path
    end
  end
  
  def find_recipients_from_params
    recipients = []
    params[:message][:recipients].each do |r|
      recipients << User.find(r)
    end
    recipients
  end
  
  def find_user_and_mailbox_from_params
    @user = User.find_by_urlname(params[:user_id])
    @mailbox = @user.mailbox[params[:mailbox_id]]
    @mailbox_name = params[:mailbox_id]
  end  
end
