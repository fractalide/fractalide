extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    ForwardingInformationBase,
    inputs( lookup_interest: any),
    inputs_array(),
    outputs(interest_miss: any),
    outputs_array(interest_hit: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("lookup_interest"));
        for p in try!(self.ports.get_output_selections("interest_hit")) {
            try!(self.ports.send_array("interest_hit", &p, ip.clone()));
        }
        Ok(())
    }
}
