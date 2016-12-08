#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;


agent! {
    io_print, edges(generic_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_a = try!(self.ports.recv("input"));
        {
            let a_reader: generic_text::Reader = try!(ip_a.read_schema());
            let a = a_reader.get_text();

            println!("{}", a?);
        }
        let _ = self.ports.send("output", ip_a);
        Ok(())
    }
}
