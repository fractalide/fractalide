extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("path.rs");
    include!("option_path.rs");
}

use self::contracts::path;
use self::contracts::option_path;

fn get(name: &str) -> Option<&str> {
    match name {
        nix-replace-me
        _ => None,
    }
}
component! {
    contract_lookup,
    inputs(input: path),
    inputs_array(),
    outputs(output: option_path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let name = try!(ip.get_reader());
        let name: path::Reader = try!(name.get_root());

        let new_path = get(try!(name.get_path()));

        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(()) },
                Some(p) => { ip.set_path(p) }
            };
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&new_ip));
        let _ = self.ports.send("output", send_ip);
        Ok(())
    }

}
