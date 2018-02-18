#lang typed/racket

(provide write-mods-default-dot-nixes)

(: write-mods-default-dot-nixes (Path String -> Void))
(define (write-mods-default-dot-nixes path language)
  (cond
    [(string=? language "rs")
     (write-file (build-path path "mods" "default.nix") rs-mods-template)
     (write-file (build-path path "mods" "rs" "default.nix") mod-rs-template)
     (write-file (build-path path "mods" "rs" "crates" "src" "lib.rs") lib-sh)
     (write-file (build-path path "mods" "rs" "crates" "Cargo.toml") cargo-toml)
     (write-file (build-path path "mods" "rs" "crates" "update.sh") update-sh)
     (file-or-directory-permissions (build-path path "mods" "rs" "crates" "update.sh") #o755)]
    [(string=? language "rkt")
     (write-file (build-path path "mods" "default.nix") rkt-mods-template)
     (write-file (build-path path "mods" "rkt" "default.nix") mod-rkt-template)]))

(: write-file (Path String -> Void))
(define (write-file path template)
  (with-output-to-file path #:exists 'replace 
    (λ () (display template))))

(define rs-mods-template #<<EOM
{ buffet }:

{
  rs = import ./rs { inherit buffet; };
}
EOM
  )

(define rkt-mods-template #<<EOM
{ buffet }:

{
  rkt = import ./rkt { inherit buffet; };
}
EOM
  )

(define mod-rs-template #<<EOM
{ buffet }:
let
  fetchgit = buffet.pkgs.fetchgit;
  buildRustCrate = buffet.pkgs.buildRustCrate;
  buildPlatform = buffet.pkgs.stdenv.buildPlatform;
  lib = buffet.pkgs.lib;
  crates = import ./crates { inherit lib buildRustCrate fetchgit buildPlatform; };
in
crates
EOM
  )

(define mod-rkt-template #<<EOM
{ buffet }:
let
  fetchgit = buffet.pkgs.fetchgit;
  buildRustCrate = buffet.pkgs.buildRustCrate;
  buildPlatform = buffet.pkgs.stdenv.buildPlatform;
  lib = buffet.pkgs.lib;
  crates = import ./crates { inherit lib buildRustCrate fetchgit buildPlatform; };
in
crates
EOM
  )

(define update-sh #<<EOM
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p carnix cargo
cargo generate-lockfile &&
carnix Cargo.lock -o default.nix
EOM
  )

(define lib-sh #<<EOM
// deliberately kept blank to fool `cargo generate-lockfile`
EOM
  )


(define cargo-toml #<<EOM
[lib]

[package]
name = "placeholder"
version = "1.1.1"

[dependencies]

EOM
  )

