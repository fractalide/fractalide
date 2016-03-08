extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    PendingInformationTable,
    inputs( lookup_interest: any, lookup_data: any, create_entry: any, delete_entry: any),
    inputs_array(),
    outputs(interest_miss: any, interest_hit: any, data_miss: any),
    outputs_array(data_hit: any),
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
