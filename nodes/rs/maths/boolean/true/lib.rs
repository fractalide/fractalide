#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    output(output: bool),
    fn run(&mut self) -> Result<Signal> {
        self.output.output.send(true)?;
        Ok(End)
    }
}
