#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    net_ndn_router_pit, contracts(net_ndn_data, net_ndn_interest)
    inputs(lookup_interest: net_ndn_interest
        , lookup_data: net_ndn_data),
    inputs_array(),
    outputs(interest_miss: net_ndn_interest),
    outputs_array(data_hit: net_ndn_data),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        Ok(())
    }
}
