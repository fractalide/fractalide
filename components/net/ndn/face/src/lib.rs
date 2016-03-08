extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    Face,
    inputs( new_face: any),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("new_face"));
        Ok(())
    }
}
