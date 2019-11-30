class User < ApplicationRecord
  MASTER_KEY = "message"
  USER_SALT = "salt_of_18"
  USER_KEY = "user_key"
  validate :password_equality,on: :create
  validate :hashify_and_store_password,on: :create
  validates_presence_of :username, :password
  validates_uniqueness_of :username
  has_many :search_histories
  attr_accessor :password_confirmation
  
  def hashify_and_store_password
    unless self.password.blank?
      self.password = ActiveSupportMsgEncryptor.encrypt_the_given_password(self.password)
    end  
  end

  def generate_token
    @token = SecureRandom.hex(14)
  end

  def password_equality
    self.errors.add(:password, "The password and confirm password are not same") if self.password != self.password_confirmation
  end

  def assign_user_token
    generate_token
    self.token = @token
  end

  def self.verify_and_authenticate(user_object)
    username = user_object[:username]
    password = user_object[:password]
    @user = User.find_by(username: username)
    if @user
      if(ActiveSupportMsgEncryptor.decrypt_the_crypted(@user.password) == password)
        @generated_token = @user.generate_token
        @user.update_attributes(token: @generated_token)
        { verification: "done", token: @user.token, msg: ""}
      else
        { verification: "failed", token: nil, msg: ""}
      end
    else
      { verification: "failed", token: nil, msg: "No Such User Exists"}
    end
  end
end
