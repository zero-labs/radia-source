class MailboxesController < ApplicationController
  before_filter :login_required
  before_filter :find_user_and_mailbox_from_params
  
  # GET /users/:user_id/mailboxes
  # GET /users/:user_id/mailboxes.:format
  def index
    @active = 'my_account' if @user == current_user
    respond_to do |format|
      format.html # index.html.erb
      format.xml {  } # TODO
    end
  end
  
  # GET /users/:user_id/mailboxes/:id
  # GET /users/:user_id/mailboxes/:id.:format
  def show
    @user = User.find_by_urlname(params[:user_id])
    @active = 'my_account' if @user == current_user
    respond_to do |format|
      format.html # show.html.erb
      format.xml { @mailbox.to_xml } # TODO implement this method in Mailbox
    end
  end
  
  protected
  
  def find_user_and_mailbox_from_params
    @user = User.find_by_urlname(params[:user_id])
    @mailbox = @user.mailbox[params[:id]]
    @mailbox_name = params[:id]
  end
  
  def active_nav
    @active = 'users'
  end
end
