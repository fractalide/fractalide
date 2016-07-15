extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

// TODO : add ctrl-maj-meta information
component! {
    ui_js_edit_validate, contracts(generic_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(validate: generic_text, display: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        {
            let mut builder: generic_text::Builder = ip_input.init_root();
            builder.set_text("content_edited");
        }
        ip_input.action = "get_val".into();
        try!(self.ports.send("validate", ip_input));

        let mut new_ip = IP::new();
        new_ip.action = "display".into();
        try!(self.ports.send("display", new_ip));

        Ok(())
    }
}
