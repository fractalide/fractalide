#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    net_ndn_router_fib, contracts(net_ndn_interest)
    inputs( lookup_interest: net_ndn_interest),
    inputs_array(),
    outputs(interest_hit: net_ndn_interest),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        Ok(())
    }
}
