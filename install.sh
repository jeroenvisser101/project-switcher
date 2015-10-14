#!/bin/bash

if git --version &>/dev/null; then
  # Git is installed, clone repo
  git clone https://github.com/jeroenvisser101/project-switcher.git ~/.project-switcher

  # If no config file exists, we copy the default one
  if [ ! -f ~/.projects.yml ]; then
    # Install configuration files
    cp ~/.project-switcher/config/.projects.yml.dist ~/.projects.yml
  fi

  echo 'Add the following to your .bashrc or .zshrc:'
  echo '  export PATH="$HOME/.project-switcher/bin:$PATH"'
  echo '  eval "$(project-switcher --inject)"'
  echo ''
  echo 'Configuration is located in ~/.projects.yml, which you can easily edit with p --edit (or p -e)'
  echo ''
  echo 'If you come across any problems, please create an issue on GitHub.'
  echo 'https://github.com/jeroenvisser101/project-switcher/issues'
else
  echo 'Git must be installed in order to install project-switcher'
  exit
fi
