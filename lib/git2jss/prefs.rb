require 'keyring'

module Git2JSS
  class KeyringJSSPrefs

    DEFAULT_PORT = 8443

    attr_reader :pw

    attr_reader :user

    attr_reader :fqdn

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
      unless @fqdn then raise ParameterError "Please specify an FQDN for the JSS" end
      unless @user then raise ParameterError "Please specify an API user" end
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
        password = keyring.get_password "#{@fqdn}", "#{@user}"
        if not password
          keyring.set_password "#{@fqdn}", "#{@user}", "#{@pw}"
        end
      end
    end

    private 

    def load_pass(args = {})
      if args[:keyring]
        keyring = Keyring.new
        return keyring.get_password "#{@fqdn}", "#{@user}"
      else
        return args[:pw]
      end
    end
  end
end