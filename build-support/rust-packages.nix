# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-02-18";
rev = "c98fd53f5f9a9830d267b21a2ace57c4a7607507";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "0040barrs8g7109zgmwbgj8vp1slhlv5v1pilk6rq410gvrdk6s0";
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
''
