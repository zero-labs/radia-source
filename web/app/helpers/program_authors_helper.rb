module ProgramAuthorsHelper
  def get_programs
    Program.find :all, :conditions => ['active = ?', true], :order => 'name ASC' 
  end
  
  def get_users
    User.find :all, :order => 'name ASC'
  end
end
