#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    io_print, edges(generic_text)
    inputs(stdin: generic_text),
    inputs_array(),
    outputs(stdout: generic_text),
    outputs_array(),
    option(generic_text),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        {
            let reader: generic_text::Reader = opt.read_schema()?;
            let option = reader.get_text();

            //println!("{}", option?);
        }
        let mut ip_a = try!(self.ports.recv("stdin"));
        {
            let a_reader: generic_text::Reader = try!(ip_a.read_schema());
            let a = a_reader.get_text();

            println!("{:?}", a?);
        }
        self.ports.send("stdout", ip_a);
        Ok(())
    }
}
