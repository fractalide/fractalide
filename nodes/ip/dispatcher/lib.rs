#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: any),
    output(output: any),
    outarr(output: any),
    fn run(&mut self) -> Result<Signal> {
        let msg = try!(self.input.input.recv());
        send_action!(self, output, msg)?;
        Ok(End)
    }
}
