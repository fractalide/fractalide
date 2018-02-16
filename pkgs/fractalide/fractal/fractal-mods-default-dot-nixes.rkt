#lang typed/racket

(provide write-mods-default-dot-nixes)

(: write-mods-default-dot-nixes (Path String -> Void))
(define (write-mods-default-dot-nixes path language)
  (cond
    [(string=? language "rs")
     (write-file (build-path path "mods" "default.nix") rs-mods-template)
     (write-file (build-path path "mods" "rs" "default.nix") mod-rs-template)]
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