#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::str;
use std::process::Output;
use std::process::Command;

agent! {
    nucleus_find_node, edges(path, option_path)
    inputs(input: path),
    inputs_array(),
    outputs(output: option_path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let name: path::Reader = try!(ip.read_schema());
        let is_path = try!(name.get_path());
        let mut stdout: String = String::new();
        let new_path = if fs::metadata(format!("{}", is_path)).is_ok() {
            Some(is_path)
        } else {
            stdout = find_node_path(is_path);
            Some(stdout.as_str())
        };
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.build_schema::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(());},
                Some(p) => { ip.set_path(p);}
            };
        }
        self.ports.send("output", new_ip);
        Ok(())
    }
}

fn find_node_path(name: &str) -> String {
    let nixpkgs = "nixpkgs=https://github.com/NixOS/nixpkgs/archive/125ffff089b6bd360c82cf986d8cc9b17fc2e8ac.tar.gz";
    let output = Command::new("nix-build")
                            .args(&["--argstr", "debug", "true"
                                , "--argstr", "cache", "$(./support/buildCache.sh)"
                                , "-I", nixpkgs
                                , "-A", format!("nodes.{}", name).as_str()])
                            .output()
                            .expect("failed to execute process");

    match String::from_utf8(output.stdout) {
        Ok(v) => String::from(v.trim()),
        Err(e) => panic!("Name of edge contains invalid UTF-8 characters: {}", e),
    }
}
