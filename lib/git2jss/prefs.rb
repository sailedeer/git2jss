require 'keyring'

module Git2JSS
  class KeyringJSSPrefs

    DEFAULT_PORT = 8443

    attr_reader :pw

    attr_reader :user

    attr_reader :fqdn

    def initialize(args = {})
      @file = args[:file] or false
      if @file
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
      unless @fqdn raise ParameterError, "Please specify an FQDN for the JSS"
      unless @user raise ParameterError, "Please specify an API user"
      @keyring = args[:keyring] or false
      if @keyring
        @keyring = Keyring.new
        @pw = @keyring.get_password "#{@fqdn}", "#{@user}"
      else
        @pw = args[:pw]
      end
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
  end
end