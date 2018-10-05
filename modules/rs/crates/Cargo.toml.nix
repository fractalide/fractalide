{ pkgs ? import <nixpkgs> {}
, srcs ? pkgs.callPackage ./srcs.nix {}
}:

let inherit (srcs.vals) rustfbp generate_msg cardano; in

pkgs.runCommand "Cargo.toml" {} ''
cat > $out <<EOF
[lib]

[package]
name = "all_crates"
version = "1.1.1"

[dependencies]
rustfbp = { path = "${rustfbp}" }
generate_msg = { path = "${generate_msg}" }
cardano = { path = "${cardano}/cardano" }
cardano-storage = { path = "${cardano}/storage"}
storage-units = { path = "${cardano}/storage-units"}
exe-common = { path = "${cardano}/exe-common"}
protocol = { path = "${cardano}/protocol"}
nom = "3.2.1"
log = "0.4"
env_logger = "0.5"
EOF
''
