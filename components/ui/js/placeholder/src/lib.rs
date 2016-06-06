extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_placeholder, contracts(js_create, js_placeholder)
    inputs(),
    inputs_array(places: any),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(js_placeholder),
    fn run(&mut self) -> Result<()> {
        let mut ip_acc = try!(self.ports.recv("acc"));

        // Create if new
        {
            let acc_reader: js_placeholder::Reader = try!(ip_acc.get_root());
            let num = try!(acc_reader.get_places()).len();
            if num == 0 {
                let mut new_ip = IP::new();
                new_ip.action = "create".into();
                {
                    let mut builder: js_create::Builder = new_ip.init_root();
                    builder.set_html(&format!("<div id=\"{}\" style=\"{}\"></div>", &self.name, try!(acc_reader.get_css())));
                }
                try!(self.ports.send_action("output", new_ip));
            }
        }

        let places = try!(self.ports.get_input_selections("places"));
        for place in places {
            let mut ip_place = self.ports.try_recv_array("places", &place);
            if let Ok(mut ip) = ip_place {
                if ip.action == "create" {
                    ip.action = "forward_create".into();
                    let mut builder = try!(ip.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                    let new_html = {
                        let (div_style, html, name) = {
                            let reader = builder.borrow().as_reader();
                            (try!(reader.get_css()), try!(reader.get_html()), try!(reader.get_name()))
                        };
                        // Check if in acc
                        // True -> Replace in ip.get_name()
                        // False -> Insert in self.name
                        let action = if try!(is_inside_and_add(&mut ip_acc, &place)) {
                            format!("replace;{}-{};", place, self.name)
                        } else {
                            format!("insert;{};", self.name)
                        };
                        format!("{}<div id=\"{}-{}\" style=\"display:none;{}\">{}</div>", action, place, self.name, div_style, html)
                    };
                    builder.set_html(&new_html);
                } else if ip.action == "delete" {
                    let all = try!(delete_place(&mut ip_acc, &place));
                    if !all {
                        ip.action = "forward".into();
                        let mut builder = ip.init_root::<js_create::Builder>();
                        builder.set_html(&format!("delete;{}-{};", place, self.name))
                    }
                } else if ip.action == "display" {
                    {
                        let mut builder = try!(ip_acc.init_root_from_reader::<js_placeholder::Builder, js_placeholder::Reader>());
                        // Is there something already displayed?
                        {
                            let reader: js_placeholder::Reader = builder.borrow().as_reader();
                            let actual = try!(reader.get_actual());
                            if actual != "" {
                                let mut ip = IP::new();
                                ip.action = "forward".into();
                                {
                                    let mut builder = ip.init_root::<js_create::Builder>();
                                    builder.set_html(&format!("css;{}-{};display;none", actual, self.name));
                                }
                                try!(self.ports.send_action("output", ip));
                            }
                        }
                        // Set the new
                        builder.set_actual(&format!("{}", place));
                    }
                    ip.action = "forward".into();
                    let mut builder = ip.init_root::<js_create::Builder>();
                    builder.set_html(&format!("css;{}-{};display;block", place, self.name))
                }
                try!(self.ports.send_action("output", ip));
            }
        }

        try!(self.ports.send("acc", ip_acc));

        Ok(())
    }
}

fn is_inside_and_add(acc: &mut IP, port: &str) -> Result<bool> {
    let mut vec: Vec<String> = vec![];
    {
        let acc: js_placeholder::Reader = try!(acc.get_root());
        let acc_places = try!(acc.get_places());
        let mut create = false;
        if acc_places.len() == 0 { create = true; }
        for i in 0..acc_places.len() {
            let p = try!(acc_places.get(i));
            if p == port { return Ok(true); }
            vec.push(p.into());
        }
    }
    // Add it
    let mut builder = acc.init_root::<js_placeholder::Builder>();
    let mut init = builder.init_places((vec.len() + 1) as u32);
    let mut i = 0;
    for p in vec {
        init.borrow().set(i, &p);
        i += 1;
    }
    init.borrow().set(i, port);
    Ok(false)
}

fn delete_place(acc: &mut IP, port: &str) -> Result<bool> {
    let mut vec: Vec<String> = vec![];
    {
        let acc: js_placeholder::Reader = try!(acc.get_root());
        let acc_places = try!(acc.get_places());
        for i in 0..acc_places.len() {
            let p = try!(acc_places.get(i));
            if p != port { vec.push(p.into()); }
        }
    }
    let mut builder = acc.init_root::<js_placeholder::Builder>();
    let mut init = builder.init_places((vec.len()) as u32);
    if vec.len() == 0 {
        return Ok(true);
    } else {
        let mut i = 0;
        for p in vec {
            init.borrow().set(i, &p);
            i += 1;
        }
        return Ok(false);
    }
}
