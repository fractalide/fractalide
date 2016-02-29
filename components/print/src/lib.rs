extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("generic_text.rs");
}
use contracts::generic_text;

component! {
    print_comp,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(generic_text),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("input"));

        let mut opt = self.recv_option();
        let text = try!(opt.get_reader());
        let text: generic_text::Reader = try!(text.get_root());

        println!("{}", try!(text.get_text()));

        let _ = self.ports.send("output", ip);

        Ok(())

    }

}
