extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(drop: any),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = try!(self.input.drop.recv());
        Ok(End)
    }
}
