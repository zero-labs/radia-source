module TimeUtils
  # Create date comparison array from a given 'from' date
  def self.time_delta(year, month = nil, day = nil)
    from = Time.local(year, month || 1, day || 1)

    to = from.next_year
    to = from.next_month unless month.blank?
    to = from + 1.day unless day.blank?
    to = to - 1 # pull off 1 second so we don't overlap onto the next day
    return [from, to]
  end
  
  # Creates a Time object from a hash of string literals
  def self.get_datetime(hsh)    
    Time.local(hsh[:year].to_i, hsh[:month].to_i, hsh[:day].to_i, hsh[:hour].to_i, hsh[:minute].to_i)
  end
end