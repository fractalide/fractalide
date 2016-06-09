extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_edit_viewer, contracts(generic_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(label: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        /*
        let mut res = "".to_string();
        {
            let mut reader: generic_text::Reader = try!(ip_input.get_root());
            res.push_str(try!(reader.get_text()));
        }
        {
            let mut builder = ip_input.init_root::<generic_text::Builder>();
            builder.set_text(&res);
        }
        */
        ip_input.action = "set_label".into();
        try!(self.ports.send("label", ip_input));

        Ok(())
    }
}
