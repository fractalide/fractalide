#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    PendingInformationTable, contracts(net_ndn_interest, net_ndn_data)
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let any: net_ndn_interest::Reader = try!(ip.get_root());
        println!("name: {:?}, nonce: {:?}",any.get_name(), any.get_nonce());

        Ok(())
    }
}
