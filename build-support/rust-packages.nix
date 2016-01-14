# This file defines the source of Rust / cargo's crates registry
#
# buildRustPackage will automatically download dependencies from the registry
# version that we define here. If you're having problems downloading / finding
# a Rust library, try updating this to a newer commit.

{ runCommand, fetchFromGitHub, git }:

let
version = "2016-01-15";
rev = "2d7296cec87cdce060233dcb54508c5b4f35f17c";

src = fetchFromGitHub {
  inherit rev;

  owner = "rust-lang";
  repo = "crates.io-index";
  sha256 = "1bx3l73az46i0k0qv3zi1wkr3v27g40c2zh7xiqcb05ql1r67cbh";
};

in

runCommand "rustRegistry-${version}-${builtins.substring 0 7 rev}" {} ''
# For some reason, cargo doesn't like fetchgit's git repositories, not even
# if we set leaveDotGit to true, set the fetchgit branch to 'master' and clone
# the repository (tested with registry rev
  # 965b634156cc5c6f10c7a458392bfd6f27436e7e), failing with the message:
#
# "Target OID for the reference doesn't exist on the repository"
#
# So we'll just have to create a new git repository from scratch with the
# contents downloaded with fetchgit...

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
