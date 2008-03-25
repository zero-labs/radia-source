class EmissionsController < ApplicationController
   before_filter :send_date
   # GET /emissions
   # GET /emissions.:format
   # GET /emissions/:year
   # GET /emissions/:year.:format
   # GET /emissions/:year/:month
   # GET /emissions/:year/:month.:format
   # GET /emissions/:year/:month/:day
   # GET /emissions/:year/:month/:day.:format
   
   # Also, the same requests, scoped by program, like this:
   # GET /programs/:program_id/emissions
   def index
     @emissions = collection_from_params(params)

     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @emissions.to_xml }
     end
   end

   # GET /emissions/:year/:month/:day/:id
   # GET /emissions/:year/:month/:day/:id.:format
   # GET /programs/:program_id/emissions/:year/:month/:day/:id
   # GET /programs/:program_id/emissions/:year/:month/:day/:id.:format
   def show
     program_nav
     @emission = Emission.find(params[:id])
     @program = @emission.program
     
     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @emission.to_xml }
     end
   end
   
   # AJAX calls

   def date_selection
     program = Program.find_by_urlname(params[:program_id]) if params[:program_id]
     date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
     render :partial => 'shared/minical', :locals => { :date => date, :program => program || nil}
   end
   

   protected

   def collection_from_params(params)
     if params.has_key?(:program_id)
       program_nav
       @program = Program.find_by_urlname(params[:program_id])
       @program.find_emissions_by_date(params[:year], params[:month], params[:day])
     else
       Emission.find_all_by_date(params[:year], params[:month], params[:day])
     end
   end
   
   def program_nav
     @active = 'programs'
   end
   
   def active_nav
     @active = 'emissions'
   end
   
   def send_date
     @date = { :year => params[:year], :month => params[:month], :day => params[:day] }
   end
end
