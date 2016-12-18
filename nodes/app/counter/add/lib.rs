extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    input(input: app_counter),
    output(output: app_counter),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_add = try!(self.input.input.recv());
        let mut msg_actual = try!(self.input.input.recv());

        if &msg_add.action != "add" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        {
            let mut builder = try!(msg_actual.edit_schema::<app_counter::Builder, app_counter::Reader>());
            let actual = builder.borrow().as_reader().get_value();
            let delta = builder.borrow().as_reader().get_delta();
            builder.set_value(actual+delta);
        }

        try!(self.output.output.send(msg_actual));

        Ok(End)
    }
}
