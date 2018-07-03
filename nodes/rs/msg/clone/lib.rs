#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

agent! {
    input(input: any),
    outarr(clone: any),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        let msg = try!(self.input.input.recv());
        for sender in self.outarr.clone.values() {
            try!(sender.send(msg.clone()));
        }
        Ok(End)
    }
}
