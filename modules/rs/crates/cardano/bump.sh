#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-git

set -e
set -u
set -o pipefail

URL=https://github.com/input-output-hk/rust-cardano.git
BRANCH=refs/heads/master

if (( $# == 0 )); then
  rev=$(git ls-remote $URL | awk '$2 == "'$BRANCH'" { print $1 }')
else if (( ${#1} == 40 )); then
  rev=$1
else
  rev=$(git ls-remote $URL | awk '$2 == "'$1'" { print $1 }')
fi; fi

sha256=$(nix-prefetch-git --no-deepClone $URL $rev |
           awk -F '"'  '/sha256/ { print $4 }')

echo -n "fetchgit { url = \"$URL\"; rev = \"$rev\"; sha256 = \"$sha256\"; }" | tee cardano.nix.new
echo
mv cardano.nix{.new,}
