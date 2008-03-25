# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def arrow
    "<span class=\"arrow\">&rarr;</span>"
  end
  
  def add_crumb(text, link, highlight = false)
    { :text => text, :link => link, :highlight => highlight }
  end
end
