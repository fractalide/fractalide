
#![feature(braced_empty_structs)]
extern crate capnp;

#[macro_use]
extern crate rustfbp;

use rustfbp::component::*;

component! {
    Nand,
    inputs(input: boolean),
    inputs_array(),
    outputs(output: boolean),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut ip = self.ports.recv("input".into()).expect("cannot receive");
        let m = ip.get_reader().expect("cannot get reader");
        let m: boolean::Reader = m.get_root().expect("not a boolean reader");


        let n = m.get_boolean();
        let mut new_m = super::capnp::message::Builder::new_default();
        {
            let mut boolean = new_m.init_root::<boolean::Builder>();
            boolean.set_boolean(!n);
        }

        ip.write_builder(&new_m);
        self.ports.send("output".into(), ip).expect("cannot send date");
    }

    mod boolean_capnp {
        include!("maths_boolean_capnp.rs");
    }
    use self::boolean_capnp::boolean;
}
