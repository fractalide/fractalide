#! /usr/bin/env nix-shell
#! nix-shell -i bash -p sqlite gcc
echo Compiling cargo2nix
cd ../cargo2nix
cargo build
cd -
echo Generating lockfile
cargo generate-lockfile
echo Running Cargo2nix
../cargo2nix/target/debug/generate-nix-pkg Cargo.lock -o default.nix -i -m &&
echo Done
echo "There's a bug in cargo2nix please manually check that all build_dependencies don't resolve to an undefined nix closure.
For example if you search for winapi_build_0_0_0 this should be changed to winapi_build_0_1_1_
Please make a pull request to resolve this issue in cargo2nix :-)"
