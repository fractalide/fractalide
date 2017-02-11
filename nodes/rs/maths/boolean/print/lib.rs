extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: prim_bool),
    output(output: prim_bool),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_a = try!(self.input.input.recv());

        {
            let a_reader: prim_bool::Reader = try!(msg_a.read_schema());
            let a = a_reader.get_bool();

            println!("boolean : {:?}", a);
        }

        let _ = self.output.output.send(msg_a);

        Ok(End)
    }
}
