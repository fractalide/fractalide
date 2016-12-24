extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    input(input: any),
    output(output: any),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_delta = try!(self.input.input.recv());
        let mut msg_actual = try!(self.input.input.recv());

        if &msg_delta.action != "delta" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        {
            let mut reader: prim_text::Reader = try!(msg_delta.read_schema());
            let mut builder = try!(msg_actual.edit_schema::<app_counter::Builder, app_counter::Reader>());
            let mut text = try!(reader.get_text());
            if text == "" { text = "0"; }
            if let Ok(i) = text.parse::<i64>() {
              builder.set_delta(i);
            }
        }

        try!(self.output.output.send(msg_actual));

        Ok(End)
    }
}
