require 'yaml'
require 'optparse'

class ProjectSwitcher
  # Runs the application
  def run
    @parser = OptionParser.new do |opts|
      opts.banner = "Project Switcher\nUsage: #{ config['alias'] } [project alias]"

      opts.on('-i', '--inject', 'Injects the script into the shell.') do
        inject!
        exit
      end

      opts.on('--self-update', 'Update project-switcher to it\'s latest version') do
        update!
        exit
      end

      opts.on('-v', '--version', 'Prints the application\'s version') do
        echo "v#{ version }"
        exit
      end

      opts.on('-l', '--list', 'Lists all available projects') do
        print_projects!
        exit
      end

      opts.on('-e', '--edit', 'Opens the configuration file in the default editor') do
        exec '"${EDITOR:-vi}" ~/.projects.yml'
        exit
      end

      opts.on('-r', '--reload', 'Reloads the configuration file') do
        settings true
        echo 'Project config reloaded'
        exit
      end

      opts.on('--uninstall', 'Removes project-switcher from your system') do
        `rm -Rf ~/.project-switcher`
        echo 'You\'ll have to remove the following lines from your .bashrc/.zshrc:'
        echo '  export PATH="$HOME/.project-switcher/bin:$PATH"'
        echo '  eval "$(project-switcher --inject)"'
        echo ''
        echo 'And remove ~/.projects.yml yourself.'
        exit
      end

      opts.on('-h', '--help', 'Prints this help.') do
        help!
      end
    end

    # Parse existing options
    @parser.parse!

    project = ARGV.first

    # Check if a project has been set
    if project.nil?
      help!
    else
      # Switch to a folder
      switch_to! project
    end

  end

  # Updates the package
  def update!
    old_tag = version
    `cd ~/.project-switcher && git pull`
    new_tag = version

    # Check if the tag was updated.
    if old_tag != new_tag
      echo "Updated to v#{ new_tag }"
      print_release_notes! new_tag
    else
      echo "You have the latest version (v#{ new_tag }) already!"
    end
  end

  # Returns the current version
  def version
    `cd ~/.project-switcher && git describe --tags`.chomp
  end

  # Prints the url to the release notes of the latest version
  def print_release_notes!(tag)
    echo 'If you want to know what has been changed, check out our changelog,'
    echo "http://github.com/jeroenvisser101/project-switcher/releases/tag/#{tag}"
  end

  # Switches directories to specified project
  def switch_to!(project_key)
    # Check if the project is defined
    if projects.keys.include? project_key
      run_hook :before, (project = projects[project_key])

      exec "cd #{ File.expand_path(project['path']) }"
      echo "Now working in #{ project['name'] }"

      run_hook :after, project
      exit
    else
      echo "Project \"#{ project_key }\" not found"
      print_possible_matches(project_key)
      exit
    end
  end

  def print_possible_matches(project_key)
    possible_matches = Array.new
    projects.each do |key, value|
        if key.include?(project_key.downcase)
           possible_matches << key
        end 
    end
    if possible_matches.length > 0
      echo "Did you mean:"
      possible_matches.each { |p| echo p }
    end
  end

  # Runs hooks specified in ~/.projects.yml
  def run_hook(type, project)
    if type == :before
      exec config['before_switch'] unless config['before_switch'].nil?
      exec project['before_switch'] unless project['before_switch'].nil?
    elsif type == :after
      exec config['after_switch'] unless config['after_switch'].nil?
      exec project['after_switch'] unless project['after_switch'].nil?
    end
  end

  # Initiates the switcher in the current shell
  def inject!
    exec "#{ config['alias'] } () { eval \"$(project-switcher $@)\" }"
  end

  # Prints help for the application
  def help!
    echo @parser.help
    echo ''
    echo 'Available projects:'
    print_projects!
    exit
  end

  # (re)loads all configuration in the memory.
  def settings(reload = false)
    if reload
      @settings = YAML.load_file File.expand_path('~/.projects.yml')
    else
      @settings ||= YAML.load_file File.expand_path('~/.projects.yml')
    end
  end

  # Returns all projects configured in ~/.projects.yml
  def projects
    settings['projects']
  end

  # Returns program config
  def config
    settings['config']
  end

  # Prints all available projects
  def print_projects!
    projects.each do |key, project|
      echo "  #{ key }: #{ project['name'] } (#{ project['path'] })"
    end
  end

  # Echo's a string
  def echo(str)
    puts "echo '#{ str.gsub(/'/, "'\"'\"'") }'"
  end

  # This executes it in the user's shell
  def exec(arg)
    puts arg
  end
end
