extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("maths_boolean.rs");
}
use self::contract_capnp::maths_boolean;

use std::thread;

component! {
    Nand,
    inputs(input: maths_boolean),
    inputs_array(),
    outputs(output: maths_boolean),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_a = try!(self.ports.recv("input"));

        {
            let a_reader: maths_boolean::Reader = try!(ip_a.get_root());
            let a = a_reader.get_boolean();

            println!("boolean : {:?}", a);
        }

        let _ = self.ports.send("output", ip_a);

        Ok(())
    }
}
