extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("net_ndn_interest.rs");
    include!("net_ndn_data.rs");
}
use self::contracts::net_ndn_interest;
use self::contracts::net_ndn_data;

component! {
    ForwardingInformationBase,
    inputs(input: any),
    inputs_array(),
    outputs(interest: net_ndn_interest, data: net_ndn_data),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let interest_reader = try!(ip.get_reader());
        let interest_reader: net_ndn_interest::Reader = try!(interest_reader.get_root());
        Ok(())
    }
}
