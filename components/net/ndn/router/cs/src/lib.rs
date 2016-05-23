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
    outputs( interest_miss: net_ndn_interest),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        Ok(())
    }
}
