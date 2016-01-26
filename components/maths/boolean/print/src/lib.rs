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
    fn run(&mut self) -> Result<()> {
        let mut ip_a = try!(self.ports.recv("input".into()));

        let a_reader = try!(ip_a.get_reader());
        let a_reader: boolean::Reader = try!(a_reader.get_root());
        let a = a_reader.get_boolean();

        println!("boolean : {:?}", a);

        let _ = self.ports.send("output".into(), ip_a);

        Ok(())
    }
}
