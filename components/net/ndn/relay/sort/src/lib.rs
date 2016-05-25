#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    ForwardingInformationBase, contracts(net_ndn_interest, net_ndn_data)
    inputs(input: any),
    inputs_array(),
    outputs(interest: net_ndn_interest, data: net_ndn_data),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let interest_reader: net_ndn_interest::Reader = try!(ip.get_root());
        Ok(())
    }
}
