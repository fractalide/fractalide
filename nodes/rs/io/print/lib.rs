#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

agent! {
    input(input: prim_text),
    output(output: prim_text),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        let mut msg_a = try!(self.input.input.recv());
        {
            let a_reader: prim_text::Reader = try!(msg_a.read_schema());
            let a = a_reader.get_text();

            println!("{}", a?);
        }
        let _ = self.output.output.send(msg_a);
        Ok(End)
    }
}
