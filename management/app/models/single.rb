class Single < AudioAsset
  include RadiaSource::SingleAudioAsset
  
  acts_as_single_asset
  
  belongs_to :live_source
  
  def live?
    !self.live_source.nil?
  end
  
  def kind
    self.live_source.nil? ? :single : :live
  end
  
  def asset_name
    name = case kind
    when :live
      "Live"
    when :single
      "Single"
    end
    name + " (#{self.authored? ? 'produced by author' : 'without author'})"
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.single(:type => kind) do
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!('live-source', self.live_source.uri, :type => :string) if kind == :live
      unless options[:short]
        xml.tag!(:authored, self.authored, :type => :boolean)
        xml.tag!(:available, self.available, :type => :boolean)
        #xml.tag!(:deadline, self.deadline, :type => :string)
        xml.tag!(:length, self.length, :type => :float)
        xml.tag!('retrieval-uri', self.retrieval_uri, :type => :string)
      end
    end
  end
end
