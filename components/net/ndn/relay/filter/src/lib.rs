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
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let any = try!(ip.get_reader());
        let any: net_ndn_interest::Reader = try!(any.get_root());
        println!("name: {:?}, nonce: {:?}",any.get_name(), any.get_nonce());

        Ok(())
    }
}
