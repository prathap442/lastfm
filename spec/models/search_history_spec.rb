require 'rails_helper'

RSpec.describe SearchHistory, type: :model do
  let(:user1) do 
    FactoryBot.build(:user)  
  end
  it "should have search history when the user is valid(+ve case)" do
    user1.save
    SearchHistory.create(search_key: "random",user_id: user1.id)
  end
  it "should not save search history when the user is invalid(-ve case)" do 
    user1.save
    sl = SearchHistory.new(search_key: "random",user_id: 43)
    sl.save
    expect(sl.save).to be_eql(false)
  end
end
