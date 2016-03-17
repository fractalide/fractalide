extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("generic_text.rs");
    include!("generic_i64.rs");
}

use contract_capnp::generic_text;
use contract_capnp::generic_i64;

component! {
    app_counter_viewer,
    inputs(input: generic_i64),
    inputs_array(),
    outputs(label: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let number = {
            let mut reader: generic_i64::Reader = try!(ip_input.get_root());
            reader.get_number()
        };
        {
            let mut builder = ip_input.init_root::<generic_text::Builder>();
            builder.set_text(&format!("{}", number));
        }

        ip_input.action = "set_label".into();
        try!(self.ports.send("label", ip_input));

        Ok(())
    }
}
