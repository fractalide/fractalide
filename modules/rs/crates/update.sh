#! /usr/bin/env nix-shell
#! nix-shell -i bash -p cargo carnix

set -euo pipefail

cd "${BASH_SOURCE[0]%/*}"

nix-build Cargo.toml.nix | xargs cat > Cargo.toml.new
mv Cargo.toml{.new,}
cargo generate-lockfile
carnix generate-nix --src ./.
nix-build Cargo.nix.nix | xargs cat > Cargo.nix.new
mv Cargo.nix{.new,}
