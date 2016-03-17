extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("generic_text.rs");
}

use self::contract_capnp::generic_text;

component! {
    ip_action,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(generic_text),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        let mut ip_input = try!(self.ports.recv("input"));

        let mut reader: generic_text::Reader = try!(opt.get_root());
        ip_input.action = try!(reader.get_text()).into();

        try!(self.ports.send("output", ip_input));

        Ok(())
    }
}
