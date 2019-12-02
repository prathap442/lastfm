class SearchHistoryService
  def initialize(user)
    @user = user
  end

  def insert_into_user_search(search_key)
    success = false
    if @user.respond_to?(:search_histories)
      begin
        @user.search_histories.create(search_key: search_key)
      rescue ActiveRecord::RecordNotSaved 
        unless @user.id
          return success
          puts "the user doesnot exist so search history can\'t be created"
        end
      end
      success = true
    end
  end
end