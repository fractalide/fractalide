extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_counter_delta, contracts(app_counter, generic_text)
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_delta = try!(self.ports.recv("input"));
        let mut ip_actual = try!(self.ports.recv("input"));

        if &ip_delta.action != "delta" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        {
            let mut reader: generic_text::Reader = try!(ip_delta.get_root());
            let mut builder = try!(ip_actual.init_root_from_reader::<app_counter::Builder, app_counter::Reader>());
            if let Ok(i) = try!(reader.get_text()).parse::<i64>() {
              builder.set_delta(i);
            }
        }

        try!(self.ports.send("output", ip_actual));

        Ok(())
    }
}
