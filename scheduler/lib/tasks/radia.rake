namespace :radia do 
  namespace :scheduler do 
    def urlnameify(text)
      t = Iconv.new('ASCII//TRANSLIT', 'utf-8').iconv(text)
      t = t.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
      (t.blank?) ? '-' : t
    end
  
    namespace :programs do
      desc "Creates programs from YAML file at config/programs.yml"
      task :from_yaml => :environment do
        entries = YAML.load_file(File.dirname(__FILE__) + '/../../config/programs.yml')
        entries.each do |e|
          Program.find_or_create_by_name(e)
        end
      end

    desc "Fetches info from the calendars in config/calendars.yml"
    task :from_url => :environment do
      require  File.dirname(__FILE__) + '/../../lib/radia_source/ical'
      calendars = YAML.load_file(File.dirname(__FILE__) + '/../../config/structure_templates.yml')

      calendars.each do |struct|
        ical = RadiaSource::ICal::get_calendar(struct["url"])
        program_names = RadiaSource::ICal::get_program_names(ical)
        program_names.each do |e|
          Program.find_or_create_by_name(e)
        end
      end
    end
    
    end

    desc "Creates structure templates"
    task :structure_templates => [:live_source, :environment] do
      
      require  File.dirname(__FILE__) + '/../../lib/radia_source/ical'
      calendars = YAML.load_file(File.dirname(__FILE__) + '/../../config/structure_templates.yml')

      # Recorded broadcasts with a single audio asset

      info = calendars.select {|x| x["name"] == "Recorded"}[0]
      exit 1 if info.nil?

      b = Structure.create
      
      asset = Single.new(:authored => true)
      asset.save
      
      segment = Segment.new(:fill => true, :audio_asset => asset, :structure => b)
      segment.save
      
      recorded = StructureTemplate.new(:name => info['name'], :color => info['color'], :calendar_url => info['url'], :structure => b)
      recorded.save
      
      # Live broadcasts that span an entire structure

      info = calendars.select {|x| x["name"] == "Live"}[0]
      exit 1 if info.nil?
      b = Structure.create
      
      source = LiveSource.find_by_name('Studio')
      asset = Single.new(:live_source => source)
      asset.save
      
      segment = Segment.new(:fill => true, :audio_asset => asset, :structure => b)
      segment.save
      
      #live = StructureTemplate.new(:name => 'Live', :color => '#96F', :structure => b)
      live = StructureTemplate.new(:name => info['name'], :color => info['color'], :calendar_url => info['url'], :structure => b)
      live.save
      
      # Playlist broadcast
      info = calendars.select {|x| x["name"] == "Playlist"}[0]
      exit 1 if info.nil?
      b = Structure.create
      
      asset = Playlist.find_or_create_by_title('Some playlist!')
      
      segment = Segment.new(:fill => true, :audio_asset => asset, :structure => b)
      segment.save
      
      #playlist = StructureTemplate.new(:name => 'Playlist', :color => '#9C3', :structure => b)
      playlist = StructureTemplate.new(:name => info['name'], :color => info['color'], :calendar_url => info['url'], :structure => b)
      playlist.save

      
    end
  
    desc "Creates users from YAML file at config/users.yml"
    task :users => ["programs:from_yaml", :environment] do
      entries = YAML.load_file(File.dirname(__FILE__) + '/../../config/users.yml')
      entries.each do |e|
        login = e.has_key?("login") ? e["login"] : urlnameify(e['name'])
        u = User.find_or_create_by_name(:name => e['name'], :email => e['mail'], 
                                        :login => login, 
                                        :password => '1234', :password_confirmation => '1234')
        u.activate
        e['programs'].each do |p| 
          Authorship.create(:program => Program.find_by_name(p), :user => u, :always => true)
        end
      end
    end
    
    desc "Creates asset service"
    task :asset_service => :environment do
      if (s = AssetService.find_by_name('Upload de novos programas')).nil?
        AssetService.create(:settings => Settings.instance, :name => 'Upload de novos programas', :protocol => 'ftp', 
                            :uri => 'ftp.radiozero.pt/upload_de_novos_programas', :login => 'radiologo')
      end
    end
    
    desc "Creates singles"
    task :singles => :environment do
      singles = YAML.load_file(File.dirname(__FILE__) + '/../../config/singles.yml')
      singles.each do |s|
        if (record = Single.find_by_title(s['title'])).nil?
          Single.create(:title => s['title'], :md5_hash => s['md5_hash'], 
                                  :length => s['length'], :available => true)
        end
      end
    end
    
    desc "Creates a playlist"
    task :playlist => [:singles, :environment] do
      play = Playlist.find_or_create_by_title('Some playlist!')
      if play.playlist_elements.blank?
        Single.find(:all, :conditions => ["available = ?", true]).each do |s|
          play.playlist_elements << PlaylistElement.new(:audio_asset => s)
        end
      end
    end
    
    desc "Creates live source"
    task :live_source => :environment do
      if (s = LiveSource.find_by_name('Studio')).nil?
        LiveSource.create(:name => 'Studio', :uri => 'http://stream.radiozero.pt/live.mp3')
      end
    end

      
    
    desc "Calls all other tasks"
    task :all => [:asset_service, :singles, :structure_templates, :users, :live_source, :playlist,:environment] do 
    end
    
  end
end
