#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: any),
    output(output: any),
    option(prim_text),
    fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        let mut opt = self.recv_option();
        let mut msg_input = try!(self.input.input.recv());
        let mut reader: prim_text::Reader = try!(opt.read_schema());
        msg_input.action = try!(reader.get_text()).into();
        try!(self.output.output.send(msg_input));
        Ok(End)
    }
}
