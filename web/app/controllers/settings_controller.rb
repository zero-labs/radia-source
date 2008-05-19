class SettingsController < ApplicationController
  before_filter :login_required
  
  # GET /settings
  def show
    @settings = Settings.instance
  end
  
  # GET /settings/edit
  def edit
    
  end
  
  
  protected
  
  def active_nav
    @active = 'settings'
  end
end
