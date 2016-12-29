#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::str;
use std::process::Command;

agent! {
    input(input: fs_path),
    output(output: fs_path_option),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = self.input.input.recv()?;
        let name: fs_path::Reader = msg.read_schema()?;
        let is_path = name.get_path()?;
        let mut stdout: String = String::new();
        let new_path = if fs::metadata(format!("{}", is_path)).is_ok() {
            Some(is_path)
        } else {
            stdout = find_node_path(is_path);
            Some(stdout.as_str())
        };
        let mut new_msg = Msg::new();
        {
            let mut msg = new_msg.build_schema::<fs_path_option::Builder>();
            match new_path {
                None => { msg.set_none(()); },
                Some(p) => { msg.set_path(p); }
            };
        }
        self.output.output.send(new_msg);
        Ok(End)
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
