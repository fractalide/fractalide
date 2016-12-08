extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    halter,
    inputs(input: any),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        try!(self.ports.recv("input"));
        try!(self.ports.recv("input"));
        Ok(())
    }
}
