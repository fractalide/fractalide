#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: any),
    outarr(clone: any),
    fn run(&mut self) -> Result<Signal> {
        let msg = try!(self.input.input.recv());
        for sender in self.outarr.clone.values() {
            try!(sender.send(msg.clone()));
        }
        Ok(End)
    }
}
