extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("generic_text.rs");
}
use self::contract_capnp::generic_text;

component! {
    Print,
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_a = try!(self.ports.recv("input"));

        let a_reader = try!(ip_a.get_reader());
        let a_reader: generic_text::Reader = try!(a_reader.get_root());
        let a = a_reader.get_text();

        println!("{:?}", a);

        let _ = self.ports.send("output", ip_a);

        Ok(())
    }
}
