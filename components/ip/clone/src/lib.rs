#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    ip_clone,
    inputs(input: any),
    inputs_array(),
    outputs(),
    outputs_array(clone: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.recv("input"));
        for p in try!(self.ports.get_output_selections("clone")) {
            try!(self.ports.send_array("clone", &p, ip.clone()));
        }
        Ok(())
    }
}
