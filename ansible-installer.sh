#!/usr/bin/env bash
set -x 

HAS_ANSIBLE="$(type "ansible" &> /dev/null && echo true || echo false)"
REPO_URL="https://github.com/wotd/k3s-ansible-test.git"
VAULT_PASS_FILE=/etc/vault_pass

if [[ -z "${DEPLOY_ENV}" ]]; then
  echo "DEPLOY_ENV is not set. Aborting!"
  exit 1
fi

if [ ! -f "$VAULT_PASS_FILE" ]; then
    echo "$VAULT_PASS_FILE does not exist. Aborting!"
    exit 1
fi

# runs the given command as root (detects if we are root already)
runAsRoot() {
  if [ $EUID -ne 0 ]; then
    sudo "${@}"
  else
    "${@}"
  fi
}

executeAnsiblePlaybook() {
    ansible-pull -U $REPO_URL --vault-id ${DEPLOY_ENV}@${VAULT_PASS_FILE} -i hosts "${@}" -e "project_name=${DEPLOY_ENV}"
}

if ! $HAS_ANSIBLE; then
  echo "Missing Ansible, installing"
  runAsRoot apt update
  runAsRoot apt install -y ansible
  echo "Ansible installation completed"
else
  echo "Ansible installed"
fi

echo "Ansible Playbook execution..."
executeAnsiblePlaybook k3s-master.yaml
