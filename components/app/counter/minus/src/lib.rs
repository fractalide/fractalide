extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_counter_minus, contracts(app_counter)
    inputs(input: generic_i64),
    inputs_array(),
    outputs(output: generic_i64),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_add = try!(self.ports.recv("input"));
        let mut ip_actual = try!(self.ports.recv("input"));

        if &ip_add.action != "minus" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        {
            let mut builder = try!(ip_actual.edit_contract::<app_counter::Builder, app_counter::Reader>());
            let actual = builder.borrow().as_reader().get_value();
            let delta = builder.borrow().as_reader().get_delta();
            builder.set_value(actual-delta);
        }

        try!(self.ports.send("output", ip_actual));

        Ok(())
    }
}
