namespace :radia do 

  def urlnameify(text)
    t = Iconv.new('ASCII//TRANSLIT', 'utf-8').iconv(text)
    t = t.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
    (t.blank?) ? '-' : t
  end

  desc "Creates programs from YAML file at config/programs.yml"
  task :programs => :environment do
    entries = YAML.load_file(File.dirname(__FILE__) + '/../../config/programs.yml')
    entries.each do |e|
      Program.find_or_create_by_name(e)
    end
  end
  
  desc "Creates emission types"
  task :emission_types => :environment do
    b = Bloc.create
    recorded = EmissionType.new(:name => 'Recorded', :color => '#69C', :bloc => b)
    recorded.save
    b = Bloc.create
    live = EmissionType.new(:name => 'Live', :color => '#96F', :bloc => b)
    live.save
    b = Bloc.create
    playlist = EmissionType.new(:name => 'Playlist', :color => '#9C3', :bloc => b)
    playlist.save
  end

  desc "Creates authors from YAML file at config/authors.yml"
  task :authors => [:programs, :environment] do
    entries = YAML.load_file(File.dirname(__FILE__) + '/../../config/authors.yml')
    entries.each do |e|
      u = User.find_or_create_by_name(:name => e['name'], :email => e['mail'], 
                                      :login => urlnameify(e['name']), 
                                      :password => '1234', :password_confirmation => '1234')
      u.activate
      e['programs'].each do |p| 
        Authorship.create(:program => Program.find_by_name(p), :user => u, :always => true)
      end
    end
  end
  
  desc "Creates admin user"
  task :create_admin => :environment do
    # Create admin
    u = User.find_or_create_by_name(:name => 'Daniel Zacarias', :email => 'daniel.zacarias@gmail.com', 
                                    :login => 'zaki', :password => '1234', :password_confirmation => '1234')
    u.activate
    u.give_role 'admin'
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
    if (s = LiveSource.find_by_title('Studio')).nil?
      LiveSource.create(:title => 'Studio', :uri => 'http://stream.radiozero.pt/')
    end
  end
  
  desc "Calls all other tasks"
  task :all => [:asset_service, :singles, :emission_types, :create_admin, :authors, :live_source, :playlist,:environment] do 
  end
end