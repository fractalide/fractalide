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
    PendingInformationTable,
    inputs(lookup_interest: net_ndn_interest
        , lookup_data: net_ndn_data
        , create_entry: net_ndn_interest
        , delete_entry: net_ndn_interest),
    inputs_array(),
    outputs(interest_miss: net_ndn_interest
        , interest_hit: net_ndn_interest
        , data_miss: net_ndn_data),
    outputs_array(data_hit: net_ndn_data),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("lookup_interest"));
        for p in try!(self.ports.get_output_selections("data_hit")) {
            try!(self.ports.send_array("data_hit", &p, ip.clone()));
        }
        Ok(())
    }
}
