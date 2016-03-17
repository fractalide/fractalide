extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("generic_i64.rs");
}

use contract_capnp::generic_i64;

component! {
    app_counter_add,
    inputs(input: generic_i64),
    inputs_array(),
    outputs(output: generic_i64),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_add = try!(self.ports.recv("input"));
        let mut ip_actual = try!(self.ports.recv("input"));

        if &ip_add.action != "add" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        {
            let mut builder = try!(ip_actual.init_root_from_reader::<generic_i64::Builder, generic_i64::Reader>());
            let actual = builder.borrow().as_reader().get_number();
            builder.set_number(actual+1);
        }

        try!(self.ports.send("output", ip_actual));

        Ok(())
    }
}
