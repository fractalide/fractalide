extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    app_counter_delta, edges(app_counter, generic_text)
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
            let mut reader: generic_text::Reader = try!(ip_delta.read_edge());
            let mut builder = try!(ip_actual.edit_edge::<app_counter::Builder, app_counter::Reader>());
            let mut text = try!(reader.get_text());
            if text == "" { text = "0"; }
            if let Ok(i) = text.parse::<i64>() {
              builder.set_delta(i);
            }
        }

        try!(self.ports.send("output", ip_actual));

        Ok(())
    }
}
