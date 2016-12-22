extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    input(input: generic_u64),
    output(output: generic_u64),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_input = try!(self.input.input.recv());

        {
            let mut builder = try!(msg_input.edit_schema::<generic_u64::Builder, generic_u64::Reader>());
            let actual = builder.borrow().as_reader().get_number();
            builder.set_number(actual+1);
        }

        let _ = self.output.output.send(msg_input);
        Ok(End)
    }
}
