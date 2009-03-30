authorization do
  role :guest do
    has_permission_on :programs, :to => :read
    has_permission_on :broadcasts, :to => :read
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
  end
  
  role :registered do
    includes :guest
  end
  
  role :author do 
    includes :registered
    
    has_permission_on :broadcasts, :to => [:update] do
      if_attribute :authors => contains {user}
    end
    
    has_permission_on :programs, :to => [:update] do 
      if_attribute :authors => contains {user}
    end
  end
  
  role :editor do
    includes :author 
    
    has_permission_on :asset_services,      :to => :manage
    has_permission_on :audio_assets,        :to => :manage
    # Author's dashboard, only supports read
    has_permission_on :authors,             :to => :read
    has_permission_on :broadcasts,          :to => :manage
    # Schedule's dashboard, only supports read
    has_permission_on :dashboard,           :to => :read
    has_permission_on :deliveries,          :to => :manage
    has_permission_on :gaps,                :to => :manage
    has_permission_on :live_sources,        :to => :manage
    #has_permission_on :messages,               :to => :manage
    has_permission_on :playlists,           :to => :manage
    has_permission_on :program_authors,     :to => :manage
    has_permission_on :program_schedule,    :to => :manage
    has_permission_on :programs,            :to => :manage
    has_permission_on :settings,            :to => :manage
    has_permission_on :singles,             :to => :manage
    has_permission_on :spots,               :to => :manage
    has_permission_on :structure_templates, :to => :manage
  end
  
  role :admin do
    has_permission_on :asset_services,      :to => :manage
    has_permission_on :audio_assets,        :to => :manage
    # Author's dashboard, only supports read
    has_permission_on :authors,             :to => :read
    has_permission_on :broadcasts,          :to => :manage
    # Schedule's dashboard, only supports read
    has_permission_on :dashboard,           :to => :read
    has_permission_on :deliveries,          :to => :manage
    has_permission_on :editors,             :to => :manage
    has_permission_on :gaps,                :to => :manage
    has_permission_on :live_sources,        :to => :manage
    has_permission_on :mailboxes,           :to => :manage
    has_permission_on :messages,            :to => :manage
    has_permission_on :playlists,           :to => :manage
    has_permission_on :program_authors,     :to => :manage
    has_permission_on :program_schedule,    :to => :manage
    has_permission_on :programs,            :to => :manage
    has_permission_on :settings,            :to => :manage
    has_permission_on :singles,             :to => :manage
    has_permission_on :spots,               :to => :manage
    has_permission_on :structure_templates, :to => :manage
    has_permission_on :users,               :to => :manage
  end
end

privileges do
  # default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage, :includes => [:create, :read, :update, :delete]
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
