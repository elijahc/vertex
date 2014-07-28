# encoding: utf-8
require 'gibberish'
require 'openssl'

SALT = ENV['BLINK_SALT']
class BsiAccount < ActiveRecord::Base
  belongs_to :user
  SERVICE_ENDPOINTS = {
    'mirror'  => 'https://websvc-mirror.bsisystems.com:2271/bsi/xmlrpc',
    'prod'    => 'https://websvc.bsisystems.com:8443/bsi/xmlrpc',
  }

  def self.find_or_create(hash)
    @account = limit(10)
    @account = BsiAccount.where( 'user_id', hash[:user].id ).where( 'username', hash[:username] ).first
    @account = BsiAccount.create( hash ) unless @account

    @account
  end

  def pass
    username = self.user.username
    pin_hash = self.user.pin_hash.to_s
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pin_hash, SALT, 2000, 256)
    decipher.key        = key
    decipher.iv         = self.anfangvektor
    encrypted_password  = self.password

    decipher.update(encrypted_password) + decipher.final
  end

  def pass=(new_password)
    username = self.user.username
    pin_hash = self.user.pin_hash.to_s
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pin_hash, SALT, 2000, 256)
    cipher.key = key
    self.anfangvektor = cipher.random_iv

    encrypted_password = cipher.update(new_password) + cipher.final

    self.password= encrypted_password
    nil
  end

  def gen_mirror_key
    return {
      :user   => self.username,
      :pass   => self.pass,
      :url    => SERVICE_ENDPOINTS['mirror'],
      :server => 'PCF'
    }
  end
end
