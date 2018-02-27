#[macro_use]
extern crate rustfbp;
extern crate capnp;
#[macro_use]
extern crate log;

agent! {
    output(output: bool),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        self.output.output.send(true)?;
        Ok(End)
    }
}
