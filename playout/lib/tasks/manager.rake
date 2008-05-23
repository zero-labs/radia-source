namespace :manager do
  desc "Creates singles"
  task :singles => :environment do
    singles = YAML.load_file(File.dirname(__FILE__) + '/../../config/singles.yml')
    singles.each do |s|
      if (record = SingleAudioAsset.find_by_title(s['title'])).nil?
        SingleAudioAsset.create(:title => s['title'], :md5_hash => s['md5_hash'], :location => s['location'], 
                                :length => s['length'], :available => true)
      end
    end
  end
end