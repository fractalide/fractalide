#! /usr/bin/env bash

set -e

nix-shell ../../racket2nix -A racket2nix-env --run "racket2nix ../../fractalide > fractalide.nix"
