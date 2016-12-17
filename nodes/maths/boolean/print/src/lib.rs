extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: maths_boolean),
    output(output: maths_boolean),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_a = try!(self.input.input.recv());

        {
            let a_reader: maths_boolean::Reader = try!(msg_a.read_schema());
            let a = a_reader.get_boolean();

            println!("boolean : {:?}", a);
        }

        let _ = self.output.output.send(msg_a);

        Ok(End)
    }
}
