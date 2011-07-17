class Launchy::Application
  #
  # The class handling the browser application and all of its schemes
  #
  class Browser < Launchy::Application
    def self.schemes
      %w[ http https ftp file ]
    end

    def windows_app_list
      %w[ start ]
    end

    def cygwin_app_list
      [ "cmd /C start" ]
    end

    def darwin_app_list
      [ find_executable( "open" ) ]
    end

    def nix_app_list
      nix_de = Launchy::Detect::NixDekstopEnvironment.browser
      app_list = %w[ xdg-open ]
      app_list << nix_de.browser
      app_list << nix_de.fallback_browsers
      app_list.flatten!
      app_list.delete_if { |b| b.nil? || (b.strip.size == 0) }
      app_list.collect { |bin| find_executable( bin ) }.find_all { |x| not x.nil? }
    end

    # use a call back mechanism to get the right app_list that is decided by the 
    # host_os_family class.
    def app_list
      host_os_family.app_list( self )
    end

    def browser_env
      return [] unless ENV['BROWSER']
      browser_env = ENV['BROWSER'].split( File::PATH_SEPARATOR )
      browser_env.flatten!
      browser_env.delete_if { |b| b.nil? || (b.strip.size == 0) }
      return browser_env
    end

    # Get the full commandline of what we are going to add the uri to
    def browser
      possibilities = (browser_env + app_list).flatten
      possibilities.each do |p|
        Launchy.log "#{self.class.name} : possibility : #{p}"
      end
      b = possibilities.shift
      Launchy.log "#{self.class.name} : Using browser value '#{b}'"
      return b
    end

    # final assembly of the command and do %s substitution 
    # http://www.catb.org/~esr/BROWSER/index.html
    def open( uri, options = {} )
      b = browser
      args = [ uri.to_s ]
      if b =~ /%s/ then
        b.gsub!( /%s/, args.shift )
      end
      run( b, args )
    end
  end
end
