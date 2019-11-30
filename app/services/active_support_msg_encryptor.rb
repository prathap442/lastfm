class ActiveSupportMsgEncryptor
  class << self
    def encrypt_the_given_password(pwd)
      encrypted_data = crypt.encrypt_and_sign(pwd)                   # => "NlFBTTMwOUV5UlA1QlNEN2xkY2d6eThYWWh..."
    end
    
    def decrypt_the_crypted(crypted_pwd)
      crypt.decrypt_and_verify(crypted_pwd)  
    end 
    
    private
    
    def crypt
      len   = ActiveSupport::MessageEncryptor.key_len
      salt  = User::USER_SALT
      key   = ActiveSupport::KeyGenerator.new(User::USER_KEY).generate_key(salt, len) # => "\x89\xE0\x156\xAC..."
      crypt = ActiveSupport::MessageEncryptor.new(key)                            # => #<ActiveSupport::MessageEncryptor ...>
    end
    
  end
end

