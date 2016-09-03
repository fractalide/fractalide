#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::str;
use std::process::Output;
use std::process::Command;

component! {
    nucleus_find_component, contracts(path, option_path)
    inputs(input: path),
    inputs_array(),
    outputs(output: option_path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let name: path::Reader = try!(ip.get_root());
        let is_path = try!(name.get_path());
        let mut stdout: String = String::new();
        let new_path = if fs::metadata(format!("{}", is_path)).is_ok() {
            Some(is_path)
        } else {
            stdout = build_component(is_path);
            Some(stdout.as_str())
        };
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(());},
                Some(p) => { ip.set_path(p);}
            };
        }
        self.ports.send("output", new_ip);
        Ok(())
    }
}

fn build_component(name: &str) -> String {
    let output = Command::new("nix-build")
                            .args(&["--argstr", "debug", "true"
                            , "--argstr", "cache", "$(./support/buildCache.sh)"
                            , "-I", "nixpkgs=/home/stewart/dev/fractalide/nixpkgs/"
                            , "--argstr", "subnet", format!("{}", name).as_str()])
                            .output()
                            .expect("failed to execute process");

    println!("status: {}", output.status);
    println!("stdout: {}", String::from_utf8_lossy(&output.stdout));
    println!("stderr: {}", String::from_utf8_lossy(&output.stderr));
    match String::from_utf8(output.stdout) {
        Ok(v) => v,
        Err(e) => panic!("Name of component contains invalid UTF-8 characters: {}", e),
    }
}
