class SingleAudioAsset < AudioAsset
  
  def to_param
    id_at_source
  end
  
  def available?
    !self.location.nil?
  end
  
  def unavailable?
    !available?
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.single do
      xml.tag!(:id, self.id_at_source, :type => :integer)
      xml.tag!(:length, self.length, :type => :float)
      xml.tag!(:status, self.status, :type => :string)
      xml.tag!(:available, self.available?, :type => :boolean)
      xml.tag!(:hash_code, self.hash_code, :type => :string)
    end
  end
  
end
