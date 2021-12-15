require 'ruby-jss'
require 'keychain'
require 'git2jss/exceptions'

module Git2JSS
  class KeyringJSSPrefs

    DEFAULT_PORT = 8443

    attr_reader :pw

    attr_reader :user

    attr_reader :fqdn

    attr_reader :port

    # initialize a new Prefs object
    def initialize(args = {})
      @file = args[:file]
      if not @file.nil?
        @fqdn = JSS::CONFIG.api_server_name
        @verify_cert = JSS::CONFIG.api_verify_cert
        @port = JSS::CONFIG.api_server_port
        @user = JSS::CONFIG.api_username
      else
        @fqdn = args[:fqdn]
        @verify_cert = args[:verify_cert] or false
        @port = args[:port] or DEFAULT_PORT
        @user = args[:user]
      end
      unless @fqdn then raise ParameterError, "FQDN is empty. Exiting..." end
      unless @user then raise ParameterError, "API username is empty. Exiting..." end
      @pw = load_pass args
    end

    # save JSS prefs to prefs file/keyring if specified
    def save
      JSS::CONFIG.api_server_name = @fqdn
      JSS::CONFIG.api_verify_cert = @verify_cert 
      JSS::CONFIG.api_server_port = @port
      JSS::CONFIG.api_username = @user
      JSS::CONFIG.save
      if @keyring
        item = @keyring.internet_passwords.where(server: "#{@fqdn}", account: "#{@user}")
        if item.nil?
          @keyring.internet_passwords.create(server: "#{@fqdn}", account: "#{@user}", protocol: Keychain::Protocols::HTTPS, password: "#{@pw}")
        else
          item.password = "#{@pw}"
          item.save!
        end
      end
      puts "JSS Credentials have been updated."
    end

    private 

    def load_pass(args = {})
      if args[:keyring]
        @keyring = Keychain.default
        item = @keyring.internet_passwords.where(server: "#{@fqdn}", account: "#{@user}")
        item = item.first
        if item.nil?
          # prompt the user for a password
          print("Please enter the API user password for #{@fqdn}: ")
          pass = gets
          pass = pass.strip
          #TODO: add some way to confirm the password, for now just assume they did it right
          @keyring.internet_passwords.create(server: "#{@fqdn}", account: "#{@user}", protocol: Keychain::Protocols::HTTPS, password: "#{pass}")
          return pass
        end
        return item.password
      else
        return args[:pw]
      end
    end
  end
end