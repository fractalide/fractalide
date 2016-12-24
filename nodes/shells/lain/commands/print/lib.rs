#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    io_print, edges(prim_text)
    inputs(stdin: prim_text),
    inputs_array(),
    outputs(stdout: prim_text),
    outputs_array(),
    option(prim_text),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        {
            let reader: prim_text::Reader = opt.read_schema()?;
            let option = reader.get_text();

            //println!("{}", option?);
        }
        let mut ip_a = try!(self.ports.recv("stdin"));
        {
            let a_reader: prim_text::Reader = try!(ip_a.read_schema());
            let a = a_reader.get_text();

            println!("{:?}", a?);
        }
        self.ports.send("stdout", ip_a);
        Ok(())
    }
}
