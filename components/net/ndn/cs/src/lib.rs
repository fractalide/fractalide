extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    ContentStore,
    inputs( lookup_interest: any, cache_data: any),
    inputs_array(),
    outputs(interest_hit: any, interest_miss: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("lookup_interest"));
        try!(self.ports.send("interest_hit", ip.clone()));
        Ok(())
    }
}
