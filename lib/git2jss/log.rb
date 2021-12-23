module Git2JSS
    ### Provides some utility functions for logging what's going on with
    ### Git2JSS
    class Logger
        include Singleton

        attr_writer :quiet, :verbose
        
        ### Initialize!
        def initialize()
            @quiet = false
            @verbose = false
        end # initialize

        def verbose_bare(msg)
            verbose_log(msg, :bare)
        end

        ### Prints a warning message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void] 
        def verbose_warn(msg)
            verbose_log(msg, :warning)
        end # verbose_warn

        ### Prints a fatal message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void]
        def verbose_fatal(msg)
            verbose_log(msg, :fatal)
        end # verbose_fatal

        ### Prints a notification message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void]
        def verbose_notify(msg)
            verbose_log(msg, :notify)
        end # verbose_notify

        def bare(msg)
            log(msg, :bare)
        end

        ### Prints a warning message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void] 
        def warn(msg)
            log(msg, :warning)
        end # warn

        ### Prints a fatal message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void]
        def fatal(msg)
            log(msg, :fatal)
        end # fatal

        ### Prints a notification message to the console.
        ###
        ### @param msg[String]
        ###
        ### @return [void]
        def notify(msg)
            log(msg, :notify)
        end # notify

        private

        ### Depending on the logging level specified by type,
        ### prints a message to the console. Only prints if
        ### if the logger is not set to be quiet.
        ###
        ### @param msg[String], type[Symbol] where type is :warning, :fatal, or :notify
        ###
        ### @return [void]
        def log(msg, type)
            if !@quiet
                case type
                when :warning
                    puts("WARNING: " + msg)
                when :fatal
                    puts("FATAL: " + msg)
                when :notify
                    puts("NOTIFY: " + msg)
                when :bare
                    puts(msg)
                else
                    $stderr.puts("Invalid log type: #{type.to_s}")
                end # case
            end # if
        end # log

        ### Depending on the logging level specified by type,
        ### prints a message to the console. Only prints if
        ### if the logger is set to be verbose.
        ###
        ### @param msg[String], type[Symbol] where type is :warning, :fatal, :notify, or :bare
        ###
        ### @return [void]
        def verbose_log(msg, type)
            if @verbose
                case type
                when :warning
                    puts("WARNING: " + msg)
                when :fatal
                    puts("FATAL: " + msg)
                when :notify
                    puts("NOTIFY: " + msg)
                when :bare
                    puts(msg)
                else
                    $stderr.puts("Invalid log type: #{type.to_s}")
                end # case
            end # if
        end # log
    end # class Logger

    # Only instance of this class
    LOGGER = Git2JSS::Logger.instance
end # module Git2JSS