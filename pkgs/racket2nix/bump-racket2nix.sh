#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash findutils gawk git nix-prefetch-git

set -e
set -u
set -o pipefail

owner=fractalide
repo=racket2nix
branch=master

SCRIPT_NAME=${BASH_SOURCE[0]##*/}

cd "${BASH_SOURCE[0]%$SCRIPT_NAME}"

if (( $# > 1 )); then
  echo "Usage: $SCRIPT_NAME [revision]"
  exit 2
fi

if (( $# == 1 )); then
  rev=$1
else
  rev=$(git ls-remote github:$owner/$repo |
          awk "/$branch/"' { print $1 }')
fi

sha256=$(nix-prefetch-git --no-deepClone https://github.com/$owner/$repo.git $rev |
           awk -F '"'  '/sha256/ { print $4 }')

tee default.nix.new <<EOF
let
  bootPkgs = import <nixpkgs> {};
  pinnedPkgs = bootPkgs.fetchFromGitHub {
    owner = "$owner";
    repo = "$repo";
    rev = "$rev";
    sha256 = "$sha256";
  };
in
import pinnedPkgs
EOF

mv default.nix{.new,}
