#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    net_ndn_router_print_interest, contracts(net_ndn_interest)
    inputs(input: net_ndn_interest),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let interest_reader: net_ndn_interest::Reader = try!(ip.get_root());
        println!("Print Interest");
        println!("name: {:?}", try!(interest_reader.get_name()));
        Ok(())
    }
}
