#!/usr/bin/env bash

HAS_ANSIBLE="$(type "ansible" &> /dev/null && echo true || echo false)"
REPO_URL="https://github.com/wotd/k3s-ansible-test.git"

# runs the given command as root (detects if we are root already)
runAsRoot() {
  if [ $EUID -ne 0 ]; then
    sudo "${@}"
  else
    "${@}"
  fi
}

if ! $HAS_ANSIBLE; then
    runAsRoot apt update
    runAsRoot apt install ansible
else
    echo "Ansible installed"
fi

executeAnsiblePlaybook() {
    ansible-pull -U $REPO_URL "${@}"
}

executeAnsiblePlaybook k3s-master.yaml
