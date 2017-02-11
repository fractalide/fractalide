extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: any),
    fn run(&mut self) -> Result<Signal> {
        try!(self.input.input.recv());
        try!(self.input.input.recv());
        Ok(End)
    }
}
