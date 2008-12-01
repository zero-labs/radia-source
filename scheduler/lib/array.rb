class Array
  # This method is an extension to the Array class as defined in
  # http://www.fivesevensix.com/articles/2005/05/20/array-to_h
  def to_h(default=nil)
    Hash[ *inject([]) { |a, value| a.push value, default || yield(value) } ]
  end
end