namespace :playout do
  desc "Creates singles"
  task :singles => :environment do
    singles = YAML.load_file(File.dirname(__FILE__) + '/../../config/singles.yml')
    singles.each do |s|
      if (record = SingleAudioAsset.find_by_id_at_source(s['title'])).nil?
        SingleAudioAsset.create(:hash_code => s['hash_code'], :location => s['location'], 
                                :length => s['length'], :id_at_source => s['id_at_source'])
      end
    end
  end
end