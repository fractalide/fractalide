#! /usr/bin/env bash

set -e

SCRIPT_NAME=${BASH_SOURCE[0]##*/}
cd "${BASH_SOURCE[0]%${SCRIPT_NAME}}"

nix-shell ../../racket2nix -A racket2nix-env --run "racket2nix ../../fractalide > fractalide.nix"
