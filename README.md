# components
canonical repository for all fractalide components created by the website and git users.

## development environment

$ ./dev-shell

## build

$ nix-build -A build release.nix

## test

$ nix-build -A tests.install release.nix
