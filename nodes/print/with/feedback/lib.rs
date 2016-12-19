#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: path),
    output(next: value_string),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = try!(self.input.input.recv());
        let path: path::Reader = try!(msg.read_schema());
        let path = try!(path.get_path());
        if path != "end" {
            let mut next_msg = Msg::new();
            {
                let mut msg = next_msg.build_schema::<value_string::Builder>();
                msg.set_value("next");
            }
            try!(self.output.next.send(next_msg));
        }
        Ok(End)
    }
}
