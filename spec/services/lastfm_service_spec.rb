require 'rails_helper'
require 'pry'
def valid_artist
  user1 = FactoryBot.create(:user, username: "prathap",password: "prathap", password_confirmation: "prathap")
  lfm_service = LastfmService.new({artist_name: "Dire Straits",user: user1})
  response_object_builder = {
    tracks: [],
    similar_artists: [],
    msg: [],
    search_logs: []  
  }
  final_response = lfm_service.artist_tracks_and_similar_artists(response_object_builder)
end

def invalid_artist
  user1 = FactoryBot.create(:user, username: "pkkk",password: "prathap", password_confirmation: "prathap")
  lfm_service = LastfmService.new({artist_name: "skfjljsdfsafj",user: user1})
  response_object_builder = {
    tracks: [],
    similar_artists: [],
    msg: [],
    search_logs: []  
  }
  final_response = lfm_service.artist_tracks_and_similar_artists(response_object_builder)
end

RSpec.describe LastfmService,type: :service do 
  describe "last fm service" do
    context "testing with one api on when the artist name is valid" do
      # make only one api call on top of it test different things
      describe "#artist_tracks_and_similar_artists" do
        before(:all) do  
          @final_response = valid_artist
        end#as the before(:all) has the effect of bleeding the user into the other examples we destroy it once the work is done
        after(:all) do 
          @user = User.first.destroy
        end     
  
        it "gets the artist info and we prove that artist count to be postive" do 
          # lets says that user search for the artist info and similar artistt
          # case: when the artist name exists  
          expect(@final_response[:tracks].count).to be_positive
        end
        it "gets the similar artists info too and we prove that the similar artists count to be positive" do 
          expect(@final_response[:similar_artists].count).to be_positive
        end
        it 'gets the search log count to be positive' do 
          expect(@final_response[:search_logs].count).to be_positive
        end
      end
    end
    
    context "when the artist name is invalid" do 
      before(:all) do 
        @final_response = invalid_artist
      end
      after(:all) do 
        @user = User.first.destroy
      end    
      describe "#artist_tracks_and_similar_artists" do
        it "gets the artist info and we prove that artist count to be postive" do 
          # lets says that user search for the artist info and similar artistt
          # case: when the artist name doesnot exists  
          expect(@final_response[:tracks].count).to be_zero
        end
        it "gets the similar artists info too and we prove that the similar artists count to be positive" do 
          expect(@final_response[:similar_artists].count).to be_zero
        end
      end    
    end

    context "testing the url responses from the services" do 
      before(:each) do 
        user1 = FactoryBot.create(:user, username: "pkkk",password: "prathap", password_confirmation: "prathap")
        @lfm_service = LastfmService.new({artist_name: "skfjljsdfsafj",user: user1})
      end
      it "builds the artists info url" do
        artist_name = @lfm_service.artist_name
        last_fm_api_key = ENV["LAST_FM_API_KEY"]
        expect(@lfm_service.get_artist_info_url).to be_eql("http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{artist_name}&api_key=#{last_fm_api_key}&format=json")
      end
      
      it "builds the artists tracks info url" do 
        artist_name = @lfm_service.artist_name
        last_fm_api_key = ENV["LAST_FM_API_KEY"]
        expect(@lfm_service.get_artist_tracks_url).to be_eql("http://ws.audioscrobbler.com/2.0/?method=artist.gettoptracks&artist=#{artist_name}&api_key=#{last_fm_api_key}&format=json")
      end
    end
  end
end