#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    io_print, contracts(generic_text)
    inputs(stdin: generic_text),
    inputs_array(),
    outputs(stdout: generic_text),
    outputs_array(),
    option(generic_text),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        {
            let reader: generic_text::Reader = opt.get_root()?;
            let option = reader.get_text();

            //println!("{}", option?);
        }
        let mut ip_a = try!(self.ports.recv("stdin"));
        {
            let a_reader: generic_text::Reader = try!(ip_a.get_root());
            let a = a_reader.get_text();

            println!("{:?}", a?);
        }
        self.ports.send("stdout", ip_a);
        Ok(())
    }
}
