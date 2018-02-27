extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: any),
    fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        try!(self.input.input.recv());
        try!(self.input.input.recv());
        Ok(End)
    }
}
