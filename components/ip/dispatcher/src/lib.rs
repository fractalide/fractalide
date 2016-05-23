extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    clone,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.recv("input"));
        let _ = self.ports.send_action("output", ip);

        Ok(())
    }
}
