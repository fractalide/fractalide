#! /usr/bin/env nix-shell
#! nix-shell --quiet -p bash coreutils gawk -i bash
set -e
set -u
set -o pipefail

function main() {
  local maybe_file=${!#}  # last argument
  local file=$(nixizeFilename "$maybe_file")

  if [[ -n $file ]] && fileHasAttr "$file" travisOrder; then
    while read attr; do
      # attr may be optional
      fileHasAttr "$file" $attr &&
        build "$@" -A $attr
    done < <(getOrder "$file")
  else
    build "$@"
  fi
}



function build() {
  local nixpkgs_paths=()

  for path in \
    $HOME/.nix-defexpr/channels/nixpkgs \
    /nix/var/nix/profiles/per-user/root/channels/nixpkgs \
  ; do
    [[ -e $path ]] &&
    nixpkgs_paths+=(-I "$(readlink "$path")")
  done

  nix-build --fallback --option restrict-eval true --arg isTravis true \
    "${nixpkgs_paths[@]}" \
    --show-trace "$@" |& subfold ${!#}
}

function subfold() {
  local prefix=$1
  awk '
    BEGIN {
      date_cmd="date +%s%N"
      current_scope="'$prefix'"
      printf "travis_fold:start:%s\r", current_scope
      printf "travis_time:start:%s\r", current_scope
      date_cmd | getline start_time
      close(date_cmd)
    }
    /^building \x27\/nix\/store\/.*[.]drv\x27/ {
      date_cmd | getline finish_time
      close(date_cmd)
      printf "travis_time:end:%s:start=%s,finish=%s,duration=%s\r", \
        current_scope, start_time, finish_time, (finish_time - start_time)
      printf "travis_fold:end:%s\r", current_scope
      current_scope=$0
      sub("building \x27/nix/store/", "", current_scope)
      sub("\x27.*", "", current_scope)
      current_scope=current_scope ".." "'$prefix'"
      printf "travis_fold:start:%s\r", current_scope
      printf "travis_time:start:%s\r", current_scope
      date_cmd | getline start_time
      close(date_cmd)
    }
    { print }
    END {
      date_cmd | getline finish_time
      close(date_cmd)
      printf "travis_time:end:%s:start=%s,finish=%s,duration=%s\r", \
        current_scope, start_time, finish_time, (finish_time - start_time)
      printf "travis_fold:end:%s\r", current_scope
    }
  '
}

function nixizeFilename() {
  local maybe_filename
  local filename

  maybe_filename=$1
  [[ -e $maybe_filename ]] || return
  [[ $maybe_filename == */* ]] && printf %s "$maybe_filename" || printf ./%s "$maybe_filename"
}

function fileHasAttr() {
  local filename=$1
  local attr=$2

  (( $(nix-instantiate --eval --argstr attr "$attr" --arg filename "$filename" \
       -E '{filename, attr}: if builtins.hasAttr attr (import filename) then 1 else 0' 2>/dev/null || true) ))
}

function getOrder() {
  # This is not overkill, this is the simplest way to parse a nix array -- let nix parse
  local filename=$1

  out=$(nix-build -E '(import <nixpkgs> {}).runCommand "order" { inherit (import '$filename') travisOrder; }
                      "for item in $travisOrder; do echo $item >> $out; done"' 2>/dev/null || true)

  [[ -z $out ]] && return
  cat $out
}

main "$@"
