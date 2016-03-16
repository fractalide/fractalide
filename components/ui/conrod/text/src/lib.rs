extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("generic_text.rs");
    include!("ui_create.rs");
}

use contract_capnp::generic_text;
use contract_capnp::ui_create;

component! {
    ui_conrod_text,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(ui_button),
    fn run(&mut self) -> Result<()> {
        let mut ip_acc = try!(self.ports.recv("acc"));
        let mut ip_input = try!(self.ports.recv("input"));

        match &ip_input.action[..] {
            "create" => {
                try!(build_create(&self, &mut ip_acc, &mut ip_input));
                let _ = self.ports.send_action("output", ip_input);
            },
            "set_label" => {
                {
                    let mut reader: generic_text::Reader = try!(ip_input.get_root());
                    let builder = try!(ip_acc.init_root_from_reader::<ui_create::Builder, ui_create::Reader>());
                    let widget = try!(builder.get_widget());
                    let mut text = widget.init_text();
                    text.set_label(try!(reader.get_text()));
                }
                try!(build_create(&self, &mut ip_acc, &mut ip_input));
                let _ = self.ports.send_action("output", ip_input);
            }
            _ => { let _ = self.ports.send_action("output", ip_input); }
        }

        try!(self.ports.send("acc", ip_acc));

        Ok(())
    }
}

fn build_create(comp: &ui_conrod_text, acc: &mut IP, out: &mut IP) -> Result<()> {
    out.action = "create".into();
    let mut builder = out.init_root::<ui_create::Builder>();
    let reader: generic_text::Reader = try!(acc.get_root());
    builder.set_name(&comp.name);
    let sender = Box::new(try!(comp.ports.get_sender("input")));
    builder.set_sender(Box::into_raw(sender) as u64);
    {
        let mut widget = builder.borrow().init_widget();
        let mut text = widget.init_text();
        text.set_label(try!(reader.get_text()));
    }
    Ok(())
}
