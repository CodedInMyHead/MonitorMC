#!/bin/bash -e

# Run with sudo.

cd "$(dirname "$0")"

WORK_DIR="$PWD"

users="${1}"
group="users"
additional_groups="docker"

fetch_ssh_keys() {
  local user="$1"
  echo "Downloading ssh keys for user $user"
  mkdir -p "/home/${user}/.ssh"
  curl -s -f -m 10 -L "https://api.github.com/users/${user}/keys" | jq -r '.[].key' > "/home/${user}/.ssh/authorized_keys"
  chown -R "${user}:${group}" "/home/${user}/.ssh"
}


echo "Adding the following users: $users"

pushd "$WORK_DIR"

  for user in $users; do
    ./create_user.sh "$user:$group" "$additional_groups"
    fetch_ssh_keys "$user"
  done

popd

echo "Done adding users."