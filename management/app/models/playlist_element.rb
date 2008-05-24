class PlaylistElement < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :audio_asset
  
  acts_as_list
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    
    xml.tag!('playlist-element') do
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!(:position, self.position, :type => :integer)
      
      xml.audio(:type => audio_asset.kind) do
        xml.tag!(:id, audio_asset.id, :type => :integer)
      end
    end
  end
end
