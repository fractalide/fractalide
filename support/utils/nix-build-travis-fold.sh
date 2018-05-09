#! /usr/bin/env nix-shell
#! nix-shell -p bash coreutils gawk -i bash
set -e
set -u
set -o pipefail

function subfold() {
  local prefix=$1
  awk '
    BEGIN {
      current_scope="'$prefix'"
      printf "travis_fold:start:%s\r", current_scope
    }
    /^building \x27\/nix\/store\/.*[.]drv\x27/ {
      if(current_scope != "") {
        printf "travis_fold:end:%s\r", current_scope
      }
      current_scope=$0
      sub("building \x27/nix/store/", "", current_scope)
      sub("\x27.*", "", current_scope)
      current_scope=current_scope ".." "'$prefix'"
      printf "travis_fold:start:%s\r", current_scope
    }
    { print }
    END {
      if(current_scope != "") {
        printf "travis_fold:end:%s\r", current_scope
      }
    }
  '
}

nix-build "$@" |& subfold ${!#}
