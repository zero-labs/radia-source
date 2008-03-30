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
     emissions_for_minical
     
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
   
   # AJAX method
   def date_selection
     date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
     if params[:program_id]
       program = Program.find_by_urlname(params[:program_id])
       emissions = program.find_emissions_by_date(date.year, date.month)
     else
       emissions = Emission.find_all_by_date(date.year, date.month) unless params[:program_id]
     end
     
     render :partial => 'shared/minical', :locals => { :date => date, :emissions => emissions, :program => program || nil}
   end
   

   protected

   def collection_from_params(params)
     send_date
     if params.has_key?(:program_id)
       program_nav
       @program = Program.find_by_urlname(params[:program_id])
       @program.find_emissions_by_date(params[:year], params[:month], params[:day])
     else
       Emission.find_all_by_date(params[:year], params[:month], params[:day])
     end
   end
   
   def emissions_for_minical
     if params[:month]
       @calemissions = @emissions 
     else
       @calemissions = Emission.find_all_by_date(params[:year] || Time.now.year, Time.now.month) unless params[:program_id]
       @calemissions = @program.find_emissions_by_date(params[:year] || Time.now.year, Time.now.month) if params[:program_id]
     end
   end
   
   def program_nav
     @active = 'programs'
   end
   
   def active_nav
     @active = 'emissions'
   end
   
   def send_date
     # Hash for breadcrumbs
     @date = { :year => params[:year], :month => params[:month], :day => params[:day] }
     # Date object for minicalendar
     if params[:day] or params[:month]
       @caldate = Date.new(params[:year].to_i, params[:month].to_i)
     else
       @caldate = Time.now
     end
   end
end
