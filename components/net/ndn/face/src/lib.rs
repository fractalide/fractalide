extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("net_ndn_interest.rs");
}
use self::contracts::net_ndn_interest;

component! {
    Face,
    inputs( new_face: net_ndn_interest),
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
