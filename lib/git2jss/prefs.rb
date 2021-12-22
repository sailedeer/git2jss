# load dependencies
require 'ruby-jss'
require 'keychain'

# load module
require 'git2jss/exceptions'

module Git2JSS

  ### Extends functionality of the JSS::Configuration class to
  ### use the system keyring to store passwords.

  class KeyringJSSPrefs

    DEFAULT_PORT = 8443

    attr_reader :pw

    attr_reader :user

    attr_reader :fqdn

    attr_reader :port

    attr_reader :preference_file_path

    ### Initialize!
    def initialize(pref_file=nil, use_keyring=false)
      @use_keyring = use_keyring
      @keyring = Keychain.default
      @preference_file_path = nil
      if !pref_file.nil?
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
      if !(@fqdn && @user)
        puts("WARNING: Critical preferences missing. Prompting for preferences.")
        prompt_for_preferences!
        save!(@preference_file_path)
      end # if
      @pw = load_password(use_keyring)
    end # initialize

    ### Save the the current preferences to teh system keyring and
    ### configured preference file.
    ###
    ### @param preference_file[String]
    ###
    ### @return [void]

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

    ### Prompt the user for new preferences.
    ###
    ### @return [void]

    def prompt_for_preferences!
      print("Please enter the FQDN of the JSS server: ")
      @fqdn = gets.chomp("\n")
      print("Please enter the API user's username for #{@fqdn}: ")
      @user = gets.chomp("\n")
      print("Please enter the port used for #{@fqdn}: ")
      @port = gets.chomp("\n")
      print("Should the API verify the SSL certificate of the server (y/N)? ")
      @verify_cert = (gets.chomp("\n")[0] == 'y')
      return
    end # prompt_for_preferences

    ### Prompt the user for a new password. Doesn't echo
    ### entered text to the terminal.
    ###
    ### @return [void]
    def prompt_for_password
      begin
        $stdin.reopen '/dev/tty' unless $stdin.tty?
        $stderr.print("Please enter the API user password for #{@fqdn}: ")
        system '/bin/stty -echo'
        pass = $stdin.gets.chomp("\n")
        $stderr.print("Please verify the API user password: ")
        pass_verify = $stdin.gets.chomp("\n")
        while !pass_verify == pass do
          $stderr.print("Please enter the API user password for #{@fqdn}: ")
          pass = $stdin.gets.chomp("\n")
          $stderr.print("Please verify the API user password: ")
          pass_verify = $stdin.gets.chomp("\n")
        end # while
      ensure
        system '/bin/stty echo'
      end # begin
    end # prompt_for_password

    ### Prompt the user for a new password without echoing
    ### input to the terminal. Updates password in place.
    ###
    ### @return [void]

    def prompt_for_password!
      pass = prompt_for_password
      @pw = pass
      return
    end # prompt_for_password

    private 

    ### Load the password from the system keyring, or 
    ### prompt the user for a password if use_keyring is false.
    ### Prompts the user for a password if it doesn't exist in the keyring.
    ###
    ### @param use_keyring[Boolean]
    ###
    ### @return [String]
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