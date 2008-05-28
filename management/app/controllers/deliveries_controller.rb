class DeliveriesController < ApplicationController
  before_filter :login_required, :except => :show
  before_filter :find_broadcast
  after_filter :send_date
  
  helper :broadcasts
  
  # GET /broadcasts/:broadcast_id/delivery
  # GET /broadcasts/:broadcast_id/delivery.:format
  def show
  end
  
  # GET /broadcasts/:broadcast_id/delivery/new
  def new    
  end
  
  # POST /broadcasts/:broadcast_id/delivery
  # POST /broadcasts/:broadcast_id/delivery.:format
  def create    
  end
  
  # GET /broadcasts/:broadcast_id/delivery/edit
  def edit    
  end
  
  # PUT /broadcasts/:broadcast_id/delivery
  # PUT /broadcasts/:broadcast_id/delivery.:format
  def update    
  end
  
  # DELETE /broadcasts/:broadcast_id/delivery
  # DELETE /broadcasts/:broadcast_id/delivery.:format
  def destroy
  end
  
  protected
  
  def find_broadcast
    @broadcast = Broadcast.find(params[:broadcast_id])
    @program = @broadcast.program
  end
  
  def active_nav
    @active = 'programs'
  end
end
