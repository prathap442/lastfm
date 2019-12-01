require 'rails_helper'
RSpec.describe User, type: :model do
  let(:user1) do
    FactoryBot.build(:user, username: "prathap",password: "prathap", password_confirmation: "prathap")
  end
  let(:user2) do 
    FactoryBot.build(:user,username: "pr",password: "pr",password_confirmation: "pr")
  end
  describe "various validations" do
    
    it "when username is missing" do 
      user1.username = ""
      expect(user1).not_to be_valid
    end
  
    it "says no two users can have the same username" do 
      user1.save
      user2.username = user1.username
      user2.save
      expect(user2.errors.full_messages).to include("Username has already been taken")
    end

    it "rejects the record if the username doesnot exist" do 
      user1.username = ""
      user1.save
      expect(user1.errors.count).to be_positive
      expect(user1.errors.full_messages).to include('Username can\'t be blank')
    end

    it "rejects the record if the password doesnot exist" do 
      user1.password = ""
      user1.save
      expect(user1.errors.full_messages).to include("Password can't be blank")
    end

    it "rejects the record if the password and password confirmation are not same" do 
      user1.password_confirmation = "Hyland"
      user1.save
      expect(user1.errors.full_messages).to include("Password The password and confirm password are not same")
    end

  end

  describe "instance methods checking" do
    it "user#hashify_and_store_password" do 
      pwd = user1.password
      user1.save
      expect(user1.password).not_to be_equal(pwd)
    end
    
    it "user#generate_token" do
      puts "this is used to check generate token functionality"
      token = user1.generate_token
      expect(token.length).to be_equal(28)    
    end
  end

  describe "class Methods Checking" do
    it "User.verify_and_authenticate(+ve case)" do 
      pwd_before_save = user1.password
      user1.save
      user2.save
      build_user_object = {username: user1.username,password: "prathap"}
      response = User.verify_and_authenticate(build_user_object)
      expect(response[:verification]).to be_eql("done")
    end

    it "User.verify_and_authenticate(-ve case)" do 
      pwd_before_save = user1.password
      user1.save
      user2.save
      build_user_object = {username: user1.username,password: "pr"}
      response = User.verify_and_authenticate(build_user_object)
      expect(response[:verification]).to be_eql("failed")
    end
  end

  it 'username presence is a must' do 
    is_expected.to validate_presence_of(:username)
  end

  it 'password presence is a must' do 
    is_expected.to validate_presence_of(:password)
  end
end
