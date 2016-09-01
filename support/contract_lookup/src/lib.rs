#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::process::Command;

component! {
    contract_lookup, contracts(path, option_path)
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
        let new_path = if fs::metadata(format!("{}", is_path)).is_ok() {
            Some(is_path)
        } else {
            lookup_path(is_path)
        };
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(());},
                Some(p) => { ip.set_path(p);}
            };
        }
        let _ = self.ports.send("output", new_ip);
        Ok(())
    }

}

fn lookup_path(name: &str) -> Option<&str> {
    match name {
        nix-replace-me
        _ => None,
    }
}
