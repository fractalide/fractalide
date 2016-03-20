# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-03-19";
rev = "281c84cf0d0127b6f9ebb28b86e0285a7e7e4e96";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "1c4h446ib140kpvq8iyzilrcaf1c55nxpyp5qs6b42xpwrplpgpa";
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
