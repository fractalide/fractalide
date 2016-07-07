extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

pub struct Portal {
    places: HashMap<String, String>,
    actual: Option<String>,
}

impl Portal {
    fn new() -> Self {
        Portal {
            places: HashMap::new(),
            actual: None,
        }
    }
}

component! {
    ui_js_visible, contracts(js_create)
    inputs(),
    inputs_array(places: any),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(), portal(Portal => Portal::new())
    fn run(&mut self) -> Result<()> {
        let places = try!(self.ports.get_input_selections("places"));
        for place in places {
            let mut ip_place = self.ports.try_recv_array("places", &place);
            if let Ok(mut ip) = ip_place {
                if ip.action == "create" {
                    ip.action = "insert_text".into();
                    try!(insert(&mut ip));
                    {
                        let reader = try!(ip.get_root::<js_create::Reader>());
                        self.portal.places.insert(place.into(), try!(reader.get_name()).into());
                    }
                } else if ip.action == "display" {
                    // Display
                    ip.action = "forward".into();
                    let mut builder = ip.init_root::<js_create::Builder>();
                    let name = try!(self.portal.places.get(&place).ok_or(result::Error::Misc("Don't get the name".into())));
                    builder.set_name(&name);
                    let mut init = builder.init_style(1);
                    init.borrow().get(0).set_key("display");
                    init.borrow().get(0).set_val("inline");
                    // Hidden if already a visible
                    match self.portal.actual {
                        Some(ref actual) => {
                            let mut ip = IP::new();
                            ip.action = "forward".into();
                            {
                                let mut builder = ip.init_root::<js_create::Builder>();
                                let name = try!(self.portal.places.get(actual).ok_or(result::Error::Misc("Don't get the name".into())));
                                builder.set_name(&name);
                                let mut init = builder.init_style(1);
                                init.borrow().get(0).set_key("display");
                                init.borrow().get(0).set_val("none");
                            }
                            try!(self.ports.send("output", ip));
                        }
                        _ => {}
                    }
                    // Set the new
                    self.portal.actual = Some(place.into());
                }
                try!(self.ports.send("output", ip));
            }
        }

        Ok(())
    }
}

fn insert(mut ip: &mut IP) -> Result<()> {
    let mut vec: Vec<(String, String)> = vec![];
    {
        let acc: js_create::Reader = try!(ip.get_root());
        let acc_places = try!(acc.get_style());
        for i in 0..acc_places.len() {
            let p = acc_places.get(i);
            vec.push((try!(p.get_key()).into(), try!(p.get_val()).into()));
        }
    }
    // Add it
    {
        let mut builder = try!(ip.init_root_from_reader::<js_create::Builder, js_create::Reader>());
        let mut init = builder.init_style((vec.len() + 1) as u32);
        let mut i = 0;
        for p in vec {
            init.borrow().get(i).set_key(&p.0);
            init.borrow().get(i).set_val(&p.1);
            i += 1;
        }
        init.borrow().get(i).set_key("display");
        init.borrow().get(i).set_val("none");
    }
    Ok(())
}
