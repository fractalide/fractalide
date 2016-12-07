#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    ip_replace,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(any),
    acc(),
    fn run(&mut self) -> Result<()> {
        let opt = self.recv_option();
        let mut ip_input = try!(self.ports.recv("input"));
        ip_input.vec = opt.vec.clone();
        ip_input.action = opt.action.clone();
        try!(self.ports.send("output", ip_input));
        Ok(())
    }
}
