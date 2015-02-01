# Project Switcher
**Project Switcher** is a simple and fast way for you to switch between projects
without typing their full path.

## Installation
Just run the following command to install the application

``` bash
\curl -sSL http://goo.gl/uHTb1g | bash -s
```

## Usage
``` bash
# This switches to the folder that has been defined in ~/.projects.yml
p [project key]

# Shows all available commands
p --help

# Show all available projects
p --list
```

## Configuration
You can configure all your projects (they must contain a key, a name and a
path).You can also configure another alias by configuring `config.alias` to the
alias you want to use.

### Sample configuration
``` yaml
# ~/.projects.yml
config:
  alias: 'p' # This is the alias used for the switcher.

projects:
  home:
    name: 'Home directory'
    path: '~/'
```

## Uninstall
Working on an uninstall command.
