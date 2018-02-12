#! /usr/bin/env nix-shell
#! nix-shell deps.nix -i bash -I fractalide=/home/stewart/dev/fractalide/fractalide
echo UPDATING DEPENDENCIES
echo Generating lockfile
cargo generate-lockfile &&
echo Running Carnix
carnix Cargo.lock -o default.nix
echo Done
