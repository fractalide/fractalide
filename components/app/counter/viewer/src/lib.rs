extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_counter_viewer, contracts(generic_text, app_counter)
    inputs(input: app_counter),
    inputs_array(),
    outputs(label: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let number = {
            let mut reader: app_counter::Reader = try!(ip_input.get_root());
            reader.get_value()
        };
        {
            let mut builder = ip_input.init_root::<generic_text::Builder>();
            builder.set_text(&format!("{}", number));
        }

        ip_input.action = "set_label".into();
        try!(self.ports.send("label", ip_input));

        Ok(())
    }
}
