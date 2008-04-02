namespace :radia do 
  
  def urlnameify(text)
    t = Iconv.new('ASCII//TRANSLIT', 'utf-8').iconv(text)
    t = t.to_s.downcase.strip.gsub(/[^-_\s[:alnum:]]/, '').squeeze(' ').tr(' ', '-')
    (t.blank?) ? '-' : t
  end
  
  
  desc "Creates programs from YAML file at config/programs.yml"
  task :programs => :environment do
    entries = YAML.load_file(File.dirname(RAILS_ROOT) + '/web/config/programs.yml')
    entries.each do |e|
      Program.find_or_create_by_name(e)
    end
  end
  
  desc "Creates authors from YAML file at config/authors.yml"
  task :authors => [:programs, :environment] do
    entries = YAML.load_file(File.dirname(RAILS_ROOT) + '/web/config/authors.yml')
    entries.each do |e|
      u = User.create(:name => e['name'], :email => e['mail'], :login => urlnameify(e['name']), 
                      :password => '1234', :password_confirmation => '1234')
      e['programs'].each do |p| 
        Authorship.create(:program => Program.find_by_name(p), :user => u, :always => true)
      end
    end
  end
end