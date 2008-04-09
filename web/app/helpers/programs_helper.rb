module ProgramsHelper
  def alphabetical_list(programs)
    hsh = {}
    letters = ('a'..'z').to_a.insert(0, '#')
    letters.each {|e| hsh[e] = [] }
    
    programs.each do |el|
      first = el.urlname.split(//)[0]
      if ((el.urlname[0] >= 48) and (el.urlname[0] <= 57))
        hsh['#'] << el
      else
        hsh[first] << el 
      end
    end
    
    render :partial => 'alphabetical', :locals => { :programs => hsh, :abc => letters}
  end
end
