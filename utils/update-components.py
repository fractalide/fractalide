#!/usr/bin/env nix-shell
#! nix-shell -i python -p python cargo python34Packages.GitPython git

import os
import subprocess
import shlex
import git
import re
import sys

# update all the components' via cargo
print "[*] Updating every component via cargo"
for root, dirs, files in os.walk("../components"):
  cmd = "cargo generate-lockfile --manifest-path " + root + "/Cargo.toml"
  args = shlex.split(cmd)
  if "Cargo.toml" in files:
    output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE).communicate()

# get crates.io head rev
print "[*] Obtaining new crates.io HEAD revision"
cmd = "git ls-remote git://github.com/rust-lang/crates.io-index.git refs/heads/master"
args = shlex.split(cmd)
head_blob, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE).communicate()
head_rev = head_blob.split('\t')[0]

# update rust-packages
print "[*] Inserting new crates.io HEAD revision into rustRegistry"
rustRegistry = "../build-support/rust-packages.nix"
find = r"^.*rev = .*$";
replace = "rev = \"%s\";" % head_rev
subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",rustRegistry])

# build rustRegistry to get the sha256, then build it again...
print "[*] Obtaining correct rustRegistry sha256 for new crates.io revision"
cmd =  "nix-build --argstr buildType debug -A support.rustRegistry"
args = shlex.split(cmd)
output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()
if error:
  m = re.search('.*instead has \xe2(.*)\xe2', error)
  if m:
    found = m.group(1)

print "[*] Inserting correct sha256 into rustRegistry"
find = r"^.*sha256 = .*$";
replace = "  sha256 = \"%s\";" % found[2:]
subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",rustRegistry])

print "[*] Building rustRegistry"
cmd =  "nix-build --argstr buildType debug -A support.rustRegistry"
args = shlex.split(cmd)
output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()
