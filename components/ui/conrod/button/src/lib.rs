extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("ui_button.rs");
    include!("ui_create.rs");
}

use contract_capnp::ui_button;
use contract_capnp::ui_create;

component! {
    ui_conrod_button,
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
                {
                    let mut builder = ip_input.init_root::<ui_create::Builder>();
                    let reader: ui_button::Reader = try!(ip_acc.get_root());
                    builder.set_name(&self.name);
                    let sender = Box::new(try!(self.ports.get_sender("input")));
                    builder.set_sender(Box::into_raw(sender) as u64);
                    {
                        let mut widget = builder.borrow().init_widget();
                        let mut button = widget.init_button();
                        button.set_label(try!(reader.get_label()));
                        button.set_enable(reader.get_enable());
                    }
                }
                let _ = self.ports.send_action("output", ip_input);
            }
            _ => { let _ = self.ports.send_action("output", ip_input); }
        }

        try!(self.ports.send("acc", ip_acc));

        Ok(())
    }
}
