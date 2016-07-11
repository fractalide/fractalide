extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_edit_create, contracts(generic_text, js_create)
    inputs(input: generic_text),
    inputs_array(),
    outputs(ph: js_create, text: js_create, input: js_create),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let text = {
            let mut reader: generic_text::Reader = try!(ip_input.get_root());
            try!(reader.get_text())
        };

        // ph
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_create::Builder>();
            builder.set_type("div");
        }
        ip.action = "create".into();
        try!(self.ports.send("ph", ip));

        // text
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_create::Builder>();
            builder.set_type("span");
            builder.set_text(&format!("{}", text));
        }
        ip.action = "create".into();
        try!(self.ports.send("text", ip));
        let mut ip = IP::new();
        ip.action = "display".into();
        try!(self.ports.send("text", ip));

        // input
        let mut new_ip = IP::new();
        {
            let mut builder = new_ip.init_root::<js_create::Builder>();
            builder.set_type("input");
            {
                let mut attr = builder.borrow().init_property(1);
                attr.borrow().get(0).set_key("value");
                attr.borrow().get(0).set_val(text);
            }
        }
        new_ip.action = "create".into();
        try!(self.ports.send("input", new_ip));


        Ok(())
    }
}
