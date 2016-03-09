extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("net_ndn_interest.rs");
}
use self::contracts::net_ndn_interest;

component! {
    ForwardingInformationBase,
    inputs( lookup_interest: net_ndn_interest),
    inputs_array(),
    outputs(interest_miss: net_ndn_interest),
    outputs_array(interest_hit: net_ndn_interest),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("lookup_interest"));
        for p in try!(self.ports.get_output_selections("interest_hit")) {
            try!(self.ports.send_array("interest_hit", &p, ip.clone()));
        }
        Ok(())
    }
}
