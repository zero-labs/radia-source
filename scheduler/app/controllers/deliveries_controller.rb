class DeliveriesController < ApplicationController
  before_filter :login_required, :except => :show
  before_filter :find_broadcast
  
  helper :broadcasts
  
  # GET /broadcasts/:broadcast_id/delivery
  # GET /broadcasts/:broadcast_id/delivery.:format
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @broadcast.content_delivery.to_xml }
    end
  end
  
  # GET /broadcasts/:broadcast_id/delivery/new
  def new    
    # new.html.erb
  end
  
  # POST /broadcasts/:broadcast_id/delivery
  # POST /broadcasts/:broadcast_id/delivery.:format
  def create
    #
  end
  
  # GET /broadcasts/:broadcast_id/delivery/edit
  def edit
    # edit.html.erb
  end
  
  # PUT /broadcasts/:broadcast_id/delivery
  # PUT /broadcasts/:broadcast_id/delivery.:format
  def update
    respond_to do |format|
      if @broadcast.deliver_single(params)
        flash[:notice] = 'Single delivered successfully'
        format.html { redirect_to program_broadcast_path(@program, @broadcast) }
        format.xml { head :ok }
      else
        flash[:error] = 'Error delivering single'
        format.html { render :action => 'new' }
        format.xml { }
      end
    end
  end
  
  # DELETE /broadcasts/:broadcast_id/delivery
  # DELETE /broadcasts/:broadcast_id/delivery.:format
  def destroy
    respond_to do |format|
      if @broadcast.cancel_delivery(params)
        flash[:notice] = 'Delivery was cancelled'
        format.html { redirect_to program_broadcast_path(@program, @broadcast) }
        format.xml { head :ok }
      else
        flash[:error] = 'Error cancelling the delivery'
        format.html { render :action => 'show' }
        format.xml { }
      end
    end
  end
  
  protected
  
  def find_broadcast
    @broadcast = Broadcast.find(params[:broadcast_id])
    @program = @broadcast.program
    broadcast_html_info
  end
  
  def active_nav
    @active = 'programs'
  end
end
