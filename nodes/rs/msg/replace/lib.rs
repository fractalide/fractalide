#[macro_use]
extern crate rustfbp;


agent! {
    input(input: any),
    output(output: any),
    option(any),
    fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
        let opt = self.recv_option();
        let mut msg_input = try!(self.input.input.recv());
        msg_input.vec = opt.vec.clone();
        msg_input.action = opt.action.clone();
        try!(self.output.output.send(msg_input));
        Ok(End)
    }
}
