#[macro_use]
extern crate rustfbp;

component! {
    magic,
    inputs(input: any),
    inputs_array(),
    outputs(),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let mut ip = try!(self.ports.recv("input"));

        let output = ip.origin.clone();
        try!(self.ports.send_array("output", &output, ip));

        Ok(())
    }
}
