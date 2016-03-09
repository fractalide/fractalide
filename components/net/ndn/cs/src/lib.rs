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
    ContentStore,
    inputs(lookup_interest: net_ndn_interest
        , cache_data: net_ndn_data),
    inputs_array(),
    outputs(interest_hit: net_ndn_interest
        , interest_miss: net_ndn_interest),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("lookup_interest"));
        let interest_reader = try!(ip.get_reader());
        let interest_reader: net_ndn_interest::Reader = try!(interest_reader.get_root());
        let name = interest_reader.get_name();
        let nonce = interest_reader.get_nonce();



        try!(self.ports.send("interest_hit", ip.clone()));
        Ok(())
    }
}
