module ProgramsHelper
  
  def authorship_days(authorship)
    days = []; i = 0
    
    Date::DAYNAMES.each do |d|
      days << Date::ABBR_DAYNAMES[i] if authorship.send(d.downcase.to_sym)
      i += 1
    end
    if authorship.always?
      "(Always)"
    else
      "(#{days.join(', ')})"
    end
  end
end
