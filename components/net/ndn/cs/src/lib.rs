extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    ContentStore,
    inputs( find_data: any, store: any),
    inputs_array(),
    outputs(hit: any, miss: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("find_data"));

            try!(self.ports.send("hit", ip.clone()));

        Ok(())
    }
}
