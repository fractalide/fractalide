# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-08-16";
rev = "edfb6755e77042d9096c4b6419ae4e012888adde";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "1zx6024hgbxpx9vmy5nswd8xxwg9w5vs2xf3v3g5c7wmxdsgsy6j";
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
