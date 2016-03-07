extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    PendingInformationTable,
    inputs( register_name: any, forward: any),
    inputs_array(),
    outputs(deleted: any, new_interest: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("register_name"));

        try!(self.ports.send("deleted",  ip.clone()));


        Ok(())
    }
}
