extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    Face,
    inputs( new_interest: any, kill_face: any),
    inputs_array(),
    outputs(name_registered: any, data_found: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("new_interest"));

        try!(self.ports.send("name_registered", ip.clone()));

        Ok(())
    }
}
