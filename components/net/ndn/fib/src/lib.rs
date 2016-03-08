extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    ForwardingInformationBase,
    inputs( forward: any),
    inputs_array(),
    outputs(data_arrives: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("forward"));


        Ok(())
    }
}
