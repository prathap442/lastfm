class User < ApplicationRecord
  validate :password_equality,on: :create
  attr_accessor :password_confirmation
  validates_presence_of :username, :password
  validates_uniqueness_of :username
  has_many :search_histories
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
    if @user.password == password
      @generated_token = @user.generate_token
      @user.update_attributes(token: @generated_token)
      {verification: "done",token: @user.token}
    else
      {verification: "failed",token: nil}
    end
  end
end
