module MessagesHelper
  def select_recipients
    users_collection = User.find(:all).reject { |u| u == current_user}
    individuals = options_from_collection_for_select(users_collection, :id, :name)
    groups_collection = [['Editors', 'editors'], ['Authors', 'authors'], ['Administrators', 'administrators']]
    groups = options_for_select(groups_collection)
    render :partial => 'recipients', :locals => { :individuals => individuals, :groups => groups }
  end
end
