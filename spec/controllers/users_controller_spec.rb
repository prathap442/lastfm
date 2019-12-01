require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "users#create" do 
    # as the request that comes to the action is of format js
    # the js format of request can be specified in params
    context "when the params are valid" do
      before(:each) do 
        post :create, params: {user: {username: "prathap", password: "prathap", password_confirmation: "prathap"},format: "js"}
      end
      it "is expected to render create.js.erb" do
        is_expected.to render_template(:create)
      end
      it "is expected to respond with the 200Ok" do 
        expect(response.status).to be(200)
      end
      it "is expected to register successfully" do 
        expect(assigns[:msg]).to be_eql("Successfully registered")
      end
    end
    
    context "when the params  are not valid" do 
      before(:each) do 
        post :create, params: {user: {username: "prathap", password: "prathap", password_confirmation: ""},format: "js"}
      end
      it "is expected to render create.js.erb" do
        is_expected.to render_template(:create)
      end
      it "is expected to respond with the 200Ok" do 
        expect(response.status).to be(200)
      end
      it "registration fails with unsuccessfull params" do 
        expect(assigns[:msg]).to be_eql("Registration failed")
      end
    end
  end

  describe "users#signup" do 
    before(:each) do 
      get :signup
    end
    it "checks on signup action(GET)" do
      expect(response.status).to be(200)
    end
  end

  describe "users#signin" do 
    before(:each) do
      get :signin
    end
    it "used to respond with the status 200" do 
      expect(response.status).to be(200)
    end
  end

  describe "users#signinpost" do
    context "when the password is valid" do
      before(:each) do 
        @user = FactoryBot.create(:user,password_confirmation: "prathap")
        post :signinpost, params:{ user:{username: "prathap",password: "prathap"},format: :js }
      end
      it "check for status code 200 when the password is correct" do 
        expect(response.status).to be(200)
      end
      it "is expected to render the template of the index of welcomes" do
        is_expected.to render_template(:signinpost)
        # because there javascript function directs the client to the welcomes#index
      end
    end

    context "when the password is invalid" do
      before(:each) do 
        @user = FactoryBot.create(:user,password_confirmation: "prathap")
        post :signinpost,params:{ user:{username: "prathap",password: "pr"},format: :js }
      end
      it "doesnot crash even when the password given is wrong" do
        expect(response.status).to be(200)
      end
      it "is expected to render the template of signin" do 
        is_expected.to render_template(:signinpost)
      end
    end
  end


  describe "users#signout" do 
    context "when signing out with the params are valid" do
      before(:each) do 
        user = FactoryBot.create(:user,password_confirmation: "prathap")
        post :signinpost, params:{ user:{username: user.username,password: "prathap"},format: :js }
        user = User.find_by(id: user.id)
        token = user.token
        post :signout, params: {user_token: token}
      end
      it "expects the response of 200" do 
        expect(response.status).to be(200)
      end
      it "expects the response of message saying logout sucessfully" do 
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['msg']).to be_eql("Successfully Logged out")
      end
    end
    context "when signing out with the params are invalid" do
      before(:each) do 
        user = FactoryBot.create(:user,password_confirmation: "prathap")
        post :signinpost, params:{ user:{username: user.username,password: "prathap"},format: :js }
        user = User.find_by(id: user.id)
        token = user.token
        post :signout, params: {user_token: token+"843"}
      end
      it "expects the response of 200" do 
        expect(response.status).to be(200)
      end
      it "expects the response of message saying logout sucessfully" do 
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['msg']).to be_eql("Logout Unsuccessfull")
      end
    end
  end

  describe "users#user_search" do
    context "when the params are valid" do
      context "when the artist name is valid" do  
        before(:each) do 
          user = FactoryBot.create(:user,password_confirmation: "prathap")
          post :signinpost, params:{ user:{username: user.username,password: "prathap"},format: :js }
          updated_user = User.find(user.id)
          get :user_search, params:{user_token: updated_user.token,artist_name: "mona",format: :json}
        end
        it "expects the 200 status code" do 
          expect(response.status).to be(200)
        end
        it "expects the response to have multiple similar artists" do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['similar_artists'].length).to be_positive 
        end
        it "expects the response to have multiple tracks" do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['tracks'].count).to be_positive 
        end
      end
      context "when the artist name is invalid" do  
        before(:each) do 
          user = FactoryBot.create(:user,password_confirmation: "prathap")
          post :signinpost, params:{ user:{username: user.username,password: "prathap"},format: :js }
          @updated_user = User.find(user.id)
         end
        it "expects the 200 status code when the artist name is invalid" do 
          get :user_search, params:{user_token: @updated_user.token,artist_name: "kkkjjjjsfsfds",format: :json}
          expect(response.status).to be(200)
        end
        it "expects the response to have zero similar artists" do
          get :user_search, params:{user_token: @updated_user.token,artist_name: "kkkjjjjsfsfds",format: :json}
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['similar_artists'].length).to be_zero 
        end
        it "expects the response to have multiple tracks" do
          get :user_search, params:{user_token: @updated_user.token,artist_name: "kkkjjjjsfsfds",format: :json}
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['tracks'].count).to be_zero 
        end
      end
    end
    context "when the params are invalid" do
      context "when the user token is invalid" do
        before(:each) do 
          user = FactoryBot.create(:user,password_confirmation: "prathap")
          post :signinpost, params:{ user:{username: user.username,password: "prathap"},format: :js }
          @updated_user = User.find(user.id)
          get :user_search, params:{user_token: "random",artist_name: "kkkjjjjsfsfds",format: :json}
        end
        it "throw's user token invalid" do 
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['msg']).to be_eql("The User token is invalid") 
        end
      end
    end
  end
end
