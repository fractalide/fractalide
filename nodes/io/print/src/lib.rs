#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;


agent! {
    input(input: generic_text),
    output(output: generic_text),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_a = try!(self.input.input.recv());
        {
            let a_reader: generic_text::Reader = try!(msg_a.read_schema());
            let a = a_reader.get_text();

            println!("{}", a?);
        }
        let _ = self.output.output.send(msg_a);
        Ok(End)
    }
}
