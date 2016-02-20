#!/usr/bin/env nix-shell
#! nix-shell -i python -p python cargo git

import os
import subprocess
import shlex
import sys
import re
import time
from itertools import chain

def query_yes_no(question, default="no"):
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = raw_input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")

result = query_yes_no(
"\n\
Proceed with caution.\n\
This script will update the dependencies of all your components and the rust registry.\n\
Ensure you are running this on a clean fractalide repository with no changes otherwise it'll eat your laundry.\n\
Proceed?")

if result == False:
  exit()

def generate_component_name( path ):
  name_list = path[14:].split("/")
  return '_'.join(map(str, name_list))

# update all the components via cargo
print "\n[*] Updating every Cargo.toml via cargo"
paths = ('../components', '../fvm', '../rustfbp', '../build-support')
for root, dirs, files in chain.from_iterable(os.walk(path) for path in paths):
  cmd = "cargo generate-lockfile --manifest-path " + root + "/Cargo.toml"
  args = shlex.split(cmd)
  if "Cargo.toml" in files:
    print "[ ] - " + root+"/Cargo.toml"
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
find = r"^.*version = .*$";
replace = "version = \"%s\";" % time.strftime('%Y-%m-%d')
subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",rustRegistry])

# build rustRegistry to get the sha256, then build it again...
print "[*] Checking for new rustRegistry sha256"
cmd =  "nix-build --argstr debug true -A support.rustRegistry"
args = shlex.split(cmd)
output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()
if error:
  if re.search('.*has wrong length for hash type.*', error):
    print error
    exit()
  if re.search('.*invalid base-32 hash.*', error):
    print error
    exit()
  m = re.search('.*instead has \xe2(.*)\xe2', error)
  if m:
    found = m.group(1)
    print "[*] Inserting latest sha256 into rustRegistry"
    find = r"^.*sha256 = .*$";
    replace = "  sha256 = \"%s\";" % found[2:]
    subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",rustRegistry])
    print "[*] Building rustRegistry with latest sha256"
    cmd =  "nix-build --argstr debug true -A support.rustRegistry"
    args = shlex.split(cmd)
    output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()


print "[*] Checking Rust components for new depsSha256"
for root, dirs, files in os.walk("../components"):
  if "Cargo.toml" in files:
    name = generate_component_name(root)
    cmd =  "nix-build --argstr debug true -A components." + name
    print "[ ] - " + name
    args = shlex.split(cmd)
    output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()
    if error:
      if re.search('.*not found', error):
        print error + "\nerror: folder hierarchy != attribute name in components/default.nix. Please fix it, commit it, then run again."
        exit()
      if re.search('.*has wrong length for hash type.*', error):
        print error
        exit()
      if re.search('.*invalid base-32 hash.*', error):
        print error
        exit()
      m = re.search('.*instead has \xe2(.*)\xe2', error)
      if m:
        print "[!] -- found new depsSha256... building "
        found = m.group(1)
        find = r"^.*depsSha256 = .*$";
        replace = "  depsSha256 = \"%s\";" % found[2:]
        subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",root+"/default.nix"])
        output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()

paths = ('../build-support/contract_lookup', '../fvm')
for root, dirs, files in chain.from_iterable(os.walk(path) for path in paths):
    if "Cargo.toml" in files:
      name = os.path.basename(root)
      if name == "fvm":
        cmd = "nix-build --argstr debug true -A fvm"
      else:
        cmd =  "nix-build --argstr debug true -A support." + os.path.basename(root)
      print "[ ] - " + name
      args = shlex.split(cmd)
      output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()
      if error:
        if re.search('.*has wrong length for hash type.*', error):
          print error
          exit()
        if re.search('.*invalid base-32 hash.*', error):
          print error
          exit()
        m = re.search('.*instead has \xe2(.*)\xe2', error)
        if m:
          print "[!] -- found new depsSha256... building "
          found = m.group(1)
          find = r"^.*depsSha256 = .*$";
          if name == "fvm":
            space = "    "
          else:
            space = "  "
          replace = space + "depsSha256 = \"%s\";" % found[2:]
          subprocess.call(["sed","-i","s/"+find+"/"+replace+"/g",root+"/default.nix"])
          output, error = subprocess.Popen(args, stdout = subprocess.PIPE, stderr= subprocess.PIPE, cwd = "..").communicate()

print "[*] Done"
