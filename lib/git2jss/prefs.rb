# load dependencies
require 'ruby-jss'
require 'keychain'

# load module
require 'git2jss/exceptions'

module Git2JSS
  class KeyringJSSPrefs

    DEFAULT_PORT = 8443

    attr_reader :pw

    attr_reader :user

    attr_reader :fqdn

    attr_reader :port

    attr_reader :preference_file_path

    # initialize a new Prefs object
    def initialize(pref_file=nil, use_keyring=false)
      @use_keyring = use_keyring
      @keyring = Keychain.default
      @preference_file_path = nil
      if not pref_file.nil?
        # reload from the file they passed, if it exists
        file_path = File.expand_path(pref_file)
        if File.exist?(file_path)
          JSS::CONFIG.reload(file_path)
          @preference_file_path = file_path
        else
          puts("WARNING: Given preference file doesn't exist. Attempting to reload from default file.")
          JSS::CONFIG.reload
        end # if
      end # if
      @fqdn = JSS::CONFIG.api_server_name
      @verify_cert = JSS::CONFIG.api_verify_cert
      @port = JSS::CONFIG.api_server_port
      @user = JSS::CONFIG.api_username
      if not @fqdn or not @user
        puts("WARNING: Critical preferences missing. Prompting for preferences.")
        prompt_for_preferences!
        puts("Would you like to save the ")
      end # if
      @pw = load_password(use_keyring)
    end # initialize

    # save JSS prefs to prefs file and keyring if specified
    def save!(preference_file = nil)
      JSS::CONFIG.api_server_name = @fqdn
      JSS::CONFIG.api_verify_cert = @verify_cert 
      JSS::CONFIG.api_server_port = @port
      JSS::CONFIG.api_username = @user

      # save to the given preference file if it exists
      preference_file_path = File.expand_path(preference_file)
      if File.exist?(preference_file_path)
        JSS::CONFIG.save(preference_file_path)
      else
        JSS::CONFIG.save
      end # if
      if @use_keyring
        item = @keyring.internet_passwords.where(server: "#{@fqdn}", account: "#{@user}").first
        if item.nil?
          @keyring.internet_passwords.create(server: "#{@fqdn}", account: "#{@user}", protocol: Keychain::Protocols::HTTPS, password: "#{@pw}")
        else
          item.password = "#{@pw}"
          item.save!
        end # if
      end # if
      puts "JSS Credentials have been updated."
    end # save!

    def prompt_for_preferences!
      print("Please enter the FQDN of the JSS server: ")
      @fqdn = gets.chomp("\n")
      print("Please enter the API user's username for #{@fqdn}: ")
      @user = gets.chomp("\n")
      print("Please enter the port used for #{@fqdn}: ")
      @port = gets.chomp("\n")
      print("Should the API verify the SSL certificate of the server (y/N)? ")
      @verify_cert = (gets.chomp("\n")[0] == 'y')
      return true
    end # prompt_for_preferences

    def prompt_for_password
      begin
        $stdin.reopen '/dev/tty' unless $stdin.tty?
        $stderr.print("Please enter the API user password for #{@fqdn}: ")
        system '/bin/stty -echo'
        pass = $stdin.gets.chomp("\n")
        $stderr.print("Please verify the API user password: ")
        pass_verify = $stdin.gets.chomp("\n")
        while not pass_verify == pass do
          $stderr.print("Please enter the API user password for #{@fqdn}: ")
          pass = $stdin.gets.chomp("\n")
          $stderr.print("Please verify the API user password: ")
          pass_verify = $stdin.gets.chomp("\n")
        end # while
      ensure
        system '/bin/stty echo'
      end # begin
    end # prompt_for_password

    def prompt_for_password!
      pass = prompt_for_password
      @pw = pass
      return true
    end # prompt_for_password

    private 

    def load_password(use_keyring)
      if use_keyring
        item = @keyring.internet_passwords.where(server: "#{@fqdn}", account: "#{@user}").first
        if item.nil?
          pass = prompt_for_password
          @keyring.internet_passwords.create(server: "#{@fqdn}", account: "#{@user}", protocol: Keychain::Protocols::HTTPS, password: "#{pass}")
          item = @keyring.internet_passwords.where(server: "#{@fqdn}", account: "#{@user}").first
        end # if
        return item.password
      else 
        return prompt_for_password
      end # if
    end # load_password
  end # class KeyringJSSPrefs
end # module Git2JSS