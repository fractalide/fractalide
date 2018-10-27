#!/usr/bin/env nix-shell
#! nix-shell --quiet -p bash gawk git nix-prefetch-git -i bash

set -euo pipefail

URL=https://github.com/fractalide/racket2nix.git
DEFAULT_REV=refs/heads/master

cd "$(dirname "${BASH_SOURCE[0]}")"

rev=${1:-$DEFAULT_REV}

if (( ${#rev} != 40 )); then
  rev=$(git ls-remote $URL | awk '$2 == "'"$rev"'" { print $1 }')
fi

nix-prefetch-git $URL $rev > default.json.new
mv default.json{.new,}
