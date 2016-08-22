# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-08-21";
rev = "c017b02d637a37f00e9c2607ab90435e689b8a8a";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "14fvav774cvkzy5mrllfhvk51s434v0s01pq6wrf7h7z5pi9jgdv";
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
