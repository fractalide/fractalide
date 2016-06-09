extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_edit_contentedited, contracts(generic_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_new = try!(self.ports.recv("input"));
        let _ = try!(self.ports.recv("input"));

        if &ip_new.action != "content_edited" {
            return Err(result::Error::Misc("Bad action".into()));
        }

        try!(self.ports.send("output", ip_new));

        Ok(())
    }
}
