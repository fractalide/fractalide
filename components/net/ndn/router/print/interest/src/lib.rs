extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("net_ndn_interest.rs");
}
use self::contracts::net_ndn_interest;

component! {
    PendingInformationTable,
    inputs(input: net_ndn_interest),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let interest_reader = try!(ip.get_reader());
        let interest_reader: net_ndn_interest::Reader = try!(interest_reader.get_root());
        println!("Print Interest");
        println!("name: {:?}", try!(interest_reader.get_name()));
        Ok(())
    }
}
