# components
canonical repository for all fractalide components created by the website and git users.

## development environment

$ ./dev-shell

## build

$ nix-build -A build release.nix

## test

$ nix-build -A tests.install release.nix

# Artifacts built

environment.variables.FRACTALIDE_CONFIG = /path/to/fractalide-working-dir/fractalide.toml
environment.variables.FRACTALIDE_DATA = /path/to/fractalide-working-dir

## TODO
Named Data Network to serve NDN Interests for components.
