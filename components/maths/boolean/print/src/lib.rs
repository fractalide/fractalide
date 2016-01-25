extern crate capnp;

#[macro_use]
extern crate rustfbp;

use rustfbp::component::*;

mod maths_boolean {
    include!("maths_boolean.rs");
}
use self::maths_boolean::boolean;

use std::thread;

component! {
    Nand,
    inputs(input: boolean),
    inputs_array(),
    outputs(output: boolean),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut ip_a = self.ports.recv("input".into()).expect("cannot receive");

        let a_reader = ip_a.get_reader().expect("cannot get reader");
        let a_reader: boolean::Reader = a_reader.get_root().expect("not a boolean reader");
        let a = a_reader.get_boolean();

        println!("boolean : {:?}", a);

        let _ = self.ports.send("output".into(), ip_a);
    }
}
