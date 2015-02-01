require 'yaml'
require 'optparse'

class ProjectSwitcher
  # Runs the application
  def run
    @parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{ config['alias'] } [project alias]"

      opts.on('-i', '--inject', 'Injects the script into the shell.') do
        inject!
        exit
      end

      opts.on('--self-update', 'Update project-switcher to it\'s latest version') do
        echo `cd ~/.project-switcher && git pull`
        echo ''
        echo 'Project is up-to-date.'
        exit
      end

      opts.on('-l', '--list', 'Lists all available projects') do
        print_projects!
        exit
      end

      opts.on('-r', '--reload', 'Reloads the configuration file') do
        settings true
        echo 'Project config reloaded'
      end

      opts.on('--uninstall', 'Removes project-switcher from your system') do
        `rm -Rf ~/.project-switcher`
        echo 'You\'ll have to remove the following lines from your .bashrc/.zshrc:'
        echo '  export PATH="$HOME/.project-switcher/bin:$PATH"'
        echo '  eval "$(project-switcher --inject)"'
        echo ''
        echo 'And remove ~/.projects.yml yourself.'
      end

      opts.on('-h', '--help', 'Prints this help.') do
        help!
      end

      opts.on
    end

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

  # Switches directories to specified project
  def switch_to!(project_key)
    # Check if the project is defined
    if projects.keys.include? project_key
      project = projects[project_key]
      exec "cd #{ File.expand_path(project['path']) }"
      echo "Now working in #{ project['name'] }"
      exit
    else
      echo "Project \"#{ project_key }\" not found"
      exit
    end
  end

  # Initiates the switcher in the current shell
  def inject!
    exec "#{ config['alias'] } () { eval \"$(project-switcher $@)\" }"
  end

  def help!
    echo @parser.help
    echo ''
    echo 'Available projects:'
    print_projects!
    exit
  end

  def settings(force = false)
    if force
      @settings = YAML.load_file File.expand_path('~/.projects.yml')
    else
      @settings ||= YAML.load_file File.expand_path('~/.projects.yml')
    end
  end

  def projects
    settings['projects']
  end

  def config
    settings['config']
  end

  def print_projects!
    projects.each do |key, project|
      echo "  #{ key }: #{ project['name'] } (#{ project['path'] })"
    end
  end

  def echo(str)
    puts "echo '#{ str.gsub(/'/, "'\"'\"'") }'"
  end

  def exec(arg)
    puts arg
  end
end
