extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_button, contracts(js_create, js_input, generic_text)
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(js_input),
    fn run(&mut self) -> Result<()> {
        let mut ip_acc = try!(self.ports.recv("acc"));
        let mut ip_input = try!(self.ports.recv("input"));

        match &ip_input.action[..] {
            "create" => {
                {
                    let mut builder = ip_input.init_root::<js_create::Builder>();
                    let reader: js_input::Reader = try!(ip_acc.get_root());
                    builder.set_name(&self.name);
                    let sender = Box::new(try!(self.ports.get_sender("input")));
                    builder.set_sender(Box::into_raw(sender) as u64);
                    let disabled = if reader.get_disabled() { " disabled" } else { "" };
                    let html = format!("<input type=\"text\" id=\"{}\" style=\"{}\" \
                                        size=\"{}\" maxlength=\"{}\" value=\"{}\" {}/>"
                                       , self.name
                                       , try!(reader.get_css())
                                       , format!("{}", reader.get_size())
                                       , format!("{}", reader.get_max_size())
                                       , try!(reader.get_label())
                                       , disabled);
                    builder.set_html(&html);
                    builder.set_css(try!(reader.get_block_css()));
                }
                let _ = self.ports.send_action("output", ip_input);
            },
            "set_label" => {
                {
                    let mut reader: generic_text::Reader = try!(ip_input.get_root());
                    let mut builder = try!(ip_acc.init_root_from_reader::<js_input::Builder, js_input::Reader>());
                    builder.set_label(try!(reader.get_text()));
                }
                try!(ip_acc.before_send());
                {
                    ip_input.action = "forward_create".into();
                    let mut builder = ip_input.init_root::<js_create::Builder>();
                    let reader: js_input::Reader = try!(ip_acc.get_root());
                    let html = format!("val;{};{}", self.name, try!(reader.get_label()));
                    builder.set_html(&html);
                }
                let _ = self.ports.send_action("output", ip_input);
            },
            "get_label" => {
                let action = {
                    let mut builder = try!(ip_input.init_root_from_reader::<generic_text::Builder, generic_text::Reader>());
                    let action: String = try!(builder.borrow().as_reader().get_text()).into();
                    let mut acc_r: js_input::Reader = try!(ip_acc.get_root());
                    builder.set_text(try!(acc_r.get_label()));
                    action
                };
                ip_input.action = action;
                let _ = self.ports.send_action("output", ip_input);

            },
            "input" => {
                {
                    let mut reader: generic_text::Reader = try!(ip_input.get_root());
                    let mut builder = try!(ip_acc.init_root_from_reader::<js_input::Builder, js_input::Reader>());
                    builder.set_label(try!(reader.get_text()));
                }
                let _ = self.ports.send_action("output", ip_input);

            }
            _ => { let _ = self.ports.send_action("output", ip_input); }
        }

        try!(self.ports.send("acc", ip_acc));

        Ok(())
    }
}
