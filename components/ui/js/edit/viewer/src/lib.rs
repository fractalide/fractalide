extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_edit_viewer, contracts(generic_text, generic_tuple_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(text: generic_text, input: generic_tuple_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let mut reader: generic_text::Reader = try!(ip_input.get_root());
        {
            let mut ip = IP::new();
            ip.action = "set_text".into();
            {
                let mut build = ip.init_root::<generic_text::Builder>();
                build.set_text(try!(reader.get_text()));
            }
            try!(self.ports.send("text", ip));
        }
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<generic_tuple_text::Builder>();
            builder.set_key("value");
            builder.set_value(try!(reader.get_text()));

        }
        ip.action = "set_property".into();
        try!(self.ports.send("input", ip));

        Ok(())
    }
}
