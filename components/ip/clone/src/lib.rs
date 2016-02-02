extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    clone,
    inputs(input: any),
    inputs_array(),
    outputs(),
    outputs_array(clone: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("input"));

        for p in try!(self.ports.get_output_selections("clone")) {
            try!(self.ports.send_array("clone", &p, ip.clone()));
        }

        Ok(())
    }
}
