# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-07-16";
rev = "412521fd09d66d879ae3a1c0f405d479bff6214a";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "0fp04k2bycsh2agj01f1brpb8jjcs3kmrz448dndpyq7h28crjmn";
};

in

runCommand "rustRegistry-${version}-${builtins.substring 0 7 rev}" {} ''
mkdir -p $out

cp -r ${src}/* $out/

cd $out

git="${git}/bin/git"

$git init
$git config --local user.email "example@example.com"
$git config --local user.name "example"
$git add .
$git commit -m 'Rust registry commit'

touch $out/touch . "$out/.cargo-index-lock"
''
