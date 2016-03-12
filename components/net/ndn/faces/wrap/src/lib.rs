extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("net_ndn_interest.rs");
}
use self::contracts::net_ndn_interest;

component! {
    Face,
    inputs( ),
    inputs_array(app: net_ndn_interest),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("wrap_interest"));
        Ok(())
    }
}
