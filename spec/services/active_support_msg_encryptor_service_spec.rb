require 'rails_helper'
require 'pry'
require "#{Rails.root}/app/services/active_support_msg_encryptor.rb"
RSpec.describe ActiveSupportMsgEncryptor,type: :service do
  let(:sample_pwd){
    "prathap"
  }
  let(:crypted_pwd){
      ActiveSupportMsgEncryptor.encrypt_the_given_password(sample_pwd)
  }
  it "encrypts the given password" do
    expect(crypted_pwd).not_to be_eql(sample_pwd) 
  end

  it "decrypts the encrypted password too" do 
    decrypted_data = ActiveSupportMsgEncryptor.decrypt_the_crypted(crypted_pwd)
    expect(decrypted_data).to be_eql(sample_pwd)
  end
end