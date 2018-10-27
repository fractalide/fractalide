#! /usr/bin/env nix-shell
#! nix-shell --quiet -i bash -p bash gnused

set -u
set -e
set -o pipefail

nix_conf=/etc/nix/nix.conf

mkdir -p $(dirname $nix_conf)
touch $nix_conf
{
  grep -vE 'sandbox' $nix_conf || true
  cat <<EOF
sandbox = true
EOF
} > ${nix_conf}.new
mv ${nix_conf}.new $nix_conf
pkill -HUP nix-daemon || true
