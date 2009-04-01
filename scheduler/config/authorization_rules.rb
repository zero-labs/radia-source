authorization do
  role :guest do
    has_permission_on :programs, :to => :read
    has_permission_on :broadcasts, :to => :read
  end
  
  role :registered do
    includes :guest
  end
  
  role :author do 
    includes :registered
    
    has_permission_on :broadcasts, :to => [:update] do
      if_attribute :authors => contains {user}
    end
    
    # 'oversee' privilege lets authors access their dashboard
    has_permission_on :programs, :to => [:update, :oversee] do 
      if_attribute :authors => contains {user}
    end
    
    has_permission_on :asset_services, :to => :browse
  end
  
  role :editor do
    includes :author 
    
    has_permission_on :asset_services,      :to => :manage
    has_permission_on :audio_assets,        :to => :manage
    has_permission_on :broadcasts,          :to => :manage
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
    has_permission_on :broadcasts,          :to => :manage
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
  # Default privilege hierarchies to facilitate RESTful Rails apps
  privilege :manage do
    includes :create, :read, :update, :delete, :oversee, :browse
  end
  
  privilege :read,   :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
  
  # Radia Source specific privileges
  
  # Privilege for 'dashboard' controllers. Applied to objects that may be 'overseen'
  privilege :oversee, :includes => [:index, :show]
  # Privilege for Asset Services, allowing access to the 'browse' AJAX action and reading actions
  privilege :browse, :includes => [:browse, :read]
end
