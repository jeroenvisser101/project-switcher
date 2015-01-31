#!/bin/bash

if git --version &>/dev/null; then
  # Git is installed, clone repo
  git clone https://github.com/jeroenvisser101/project-switcher.git ~/.project-switcher

  # Install configuration files
  ~/.project-switcher/bin/project-switcher --install

  echo 'Add the following to your .bashrc or .zshrc:'
  echo '  export PATH="$HOME/.project-switcher/bin:$PATH"'
  echo '  eval "$(project-switcher init -)"'
  echo ''
  echo 'Configuration is located in ~/.projects.yml'
  echo ''
  echo 'If you come across any problems, please create an issue on GitHub.'
  echo 'https://github.com/jeroenvisser101/project-switcher'
else
  echo "Git must be installed in order to install project-switcher"
  exit
fi
