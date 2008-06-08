module ManagementResources
  class Schedule < ActiveResource::Base    
    self.site = $playout_config['base_uri'] + '/'

    def self.fetch(dtstart = nil, dtend = nil)
      find(:one, :from => '/schedule.xml')
    end

    def to_broadcast(format)
      case format
      when :palinsesto
        to_palinsesto
      end
    end

    def to_palinsesto(options = {})
      options[:indent] ||= 2
      xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      xml.instruct! unless options[:skip_instruct]

      xml.PalinsestoXML do
        self.broadcasts.each do |bc|
          bc.to_palinsesto(xml)
        end
      end
    end
  end

end