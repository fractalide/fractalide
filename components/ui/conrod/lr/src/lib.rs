extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("ui_create.rs");
    include!("ui_lr.rs");
}

use contract_capnp::ui_lr;
use contract_capnp::ui_create;

component! {
    ui_conrod_lr,
    inputs(input: any),
    inputs_array(places: any),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(ui_ls),
    fn run(&mut self) -> Result<()> {
        let mut ip_acc = try!(self.ports.recv("acc"));
        let mut ip_input = self.ports.try_recv("input");

        let places = try!(self.ports.get_input_selections("places"));
        // check for ceate
        let create = {
            let borrow_places: Vec<&str> = places.iter().map(|p| { p.as_str() }).collect();
            let acc: ui_lr::Reader = try!(ip_acc.get_root());
            let acc_places = try!(acc.get_places());
            let mut create = false;
            if acc_places.len() == 0 { create = true; }
            for i in 0..acc_places.len() {
                let acc_p = try!(acc_places.get(i));
                if !borrow_places.contains(&acc_p) {
                    create = true;
                    break;
                }
            }
            create
        };
        if create {
            // Send create outside
            let mut create_ip = IP::new();
            {
                let mut builder = create_ip.init_root::<ui_create::Builder>();
                builder.set_name(&self.name);
                let sender = Box::new(try!(self.ports.get_sender("input")));
                builder.set_sender(Box::into_raw(sender) as u64);
                {
                    let mut widget = builder.borrow().init_widget();
                    let mut list = widget.init_lr(places.len() as u32);
                    let mut i: u32 = 0;
                    for p in &places {
                        list.borrow().set(i, &format!("{}-{}", self.name, p));
                        i += 1;
                    }
                }
            }
            create_ip.action = "create".into();
            let _ = self.ports.send_action("output", create_ip);
            // New acc ip
            {
                let mut builder: ui_lr::Builder = ip_acc.init_root();
                let mut init = builder.init_places(places.len() as u32);
                let mut i = 0;
                for p in &places {
                    init.borrow().set(i, &format!("{}-{}", self.name, p));
                    i += 1;
                }
            }
        }

        for place in places {
            let mut ip_place = self.ports.try_recv_array("places", &place);
            if let Ok(mut ip) = ip_place {
                if ip.action == "create" {
                    ip.action = "forward_create".into();
                    let mut builder = try!(ip.init_root_from_reader::<ui_create::Builder, ui_create::Reader>());
                    builder.set_id(&format!("{}-{}", self.name, place));
                }
                try!(self.ports.send_action("output", ip));
            }
        }

        try!(self.ports.send("acc", ip_acc));

        Ok(())
    }
}
