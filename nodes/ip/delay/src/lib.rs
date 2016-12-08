#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::thread;

agent! {
    ip_delay,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip_input = try!(self.ports.recv("input"));
        thread::sleep_ms(1000);
        try!(self.ports.send("output", ip_input));
        Ok(())
    }
}
