extern crate capnp;

#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

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
    component_lookup,
    inputs(input: path),
    inputs_array(),
    outputs(output: option_path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut ip = self.ports.recv("input".into()).expect("lookup: unable to receive");
        let name = ip.get_reader().expect("lookup: cannot get reader");
        let name: path::Reader = name.get_root().expect("fbp_print_graph : not a literal");

        let new_path = get(name.get_path().unwrap());

        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(()) },
                Some(p) => { ip.set_path(p) }
            };
        }
        let mut send_ip = self.allocator.ip.build_empty();
        send_ip.write_builder(&new_ip).expect("file_open: cannot write");
        let _ = self.ports.send("output".into(), send_ip);

    }

}
