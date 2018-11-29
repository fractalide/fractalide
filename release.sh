#!/usr/bin/env bash

set -euo pipefail

cd "${BASH_SOURCE[0]%/*}"

sandbox=$(nix-instantiate --eval -E 'with import <nixpkgs> {}; if stdenv.isDarwin then "" else "--option sandbox true"')

exec ./support/utils/nix-build-travis-fold.sh ${sandbox//\"/} -I fractalide=$(pwd | xargs readlink -e) --no-out-link release.nix "$@" |&
  sed -e 's/travis_.*\r//'
