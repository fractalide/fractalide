extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    Nand, edges(maths_boolean)
    inputs(input: maths_boolean),
    inputs_array(),
    outputs(output: maths_boolean),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_a = try!(self.ports.recv("input"));

        {
            let a_reader: maths_boolean::Reader = try!(ip_a.read_edge());
            let a = a_reader.get_boolean();

            println!("boolean : {:?}", a);
        }

        let _ = self.ports.send("output", ip_a);

        Ok(())
    }
}
