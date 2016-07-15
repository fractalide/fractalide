extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

// TODO : add ctrl-maj-meta information
component! {
    ui_js_edit_keyfilter, contracts(generic_text, generic_tuple_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(validate: generic_tuple_text, escape: generic_text, display: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let mut res = "".to_string();
        {
            let mut reader: generic_text::Reader = try!(ip_input.get_root());
            res.push_str(try!(reader.get_text()));
        }
        if res == "27" { // Escape
            ip_input.action = "get_model".into();
            {
                let mut builder: generic_text::Builder = ip_input.init_root();
                builder.set_text("escape");
            }
            try!(self.ports.send("escape", ip_input));
            let mut new_ip = IP::new();
            new_ip.action = "display".into();
            try!(self.ports.send("display", new_ip))
        } else if res == "13" { // Enter
            ip_input.action="get_property".into();
            {
                let mut builder: generic_tuple_text::Builder = ip_input.init_root();
                builder.set_key("content_edited");
                builder.set_value("value");
            }
            try!(self.ports.send("validate", ip_input));
            let mut new_ip = IP::new();
            new_ip.action = "display".into();
            try!(self.ports.send("display", new_ip))
        }

        Ok(())
    }
}
