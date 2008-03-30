module AuthorsHelper
  def get_programs
    Program.find :all, :conditions => ['active = ?', true], :order => 'name ASC' 
  end
  
  def get_users
    User.find :all
  end
end
