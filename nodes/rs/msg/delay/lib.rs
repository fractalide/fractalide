#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::thread;

agent! {
    input(input: any),
    output(output: any),
    fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        let msg_input = try!(self.input.input.recv());
        thread::sleep_ms(1000);
        try!(self.output.output.send(msg_input));
        Ok(End)
    }
}
