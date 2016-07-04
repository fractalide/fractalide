extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

pub struct Portal {
    places: Vec<String>,
    actual: Option<String>,
}

impl Portal {
    fn new() -> Self {
        Portal {
            places: Vec::new(),
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
                    // ip.action is "insert_content" or "forward"
                    let mut action: Option<String> = None;
                    {
                        let mut builder = try!(ip.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                        let new_html = {
                            let (div_style, html) = {
                                let reader = builder.borrow().as_reader();
                                (try!(reader.get_css()), try!(reader.get_html()))
                            };
                            // Check if in acc
                            if self.portal.places.contains(&place) {
                                action = Some("forward_create".to_string());
                                format!("html;{}-{};{}", place, self.name, html)
                            } else {
                                action = Some("insert_content".to_string());
                                let n_html = format!("<div id=\"{}-{}\" style=\"position:relative;top:0px;left:0px;display:none;{}\">{}</div>", place, self.name, div_style, html);
                                self.portal.places.push(place.into());
                                n_html
                            }
                        };
                        builder.set_html(&new_html);
                    }
                    ip.action = action.expect("unreachable");
                } else if ip.action == "delete" {
                    let pos = self.portal.places.iter()
                        .position(|el| el.as_str() == place)
                        .expect("unreachable");
                    self.portal.places.remove(pos);
                    ip.action = "forward".into();
                    {
                        let mut builder = ip.init_root::<js_create::Builder>();
                        builder.set_html(&format!("delete;{}-{};", place, self.name))
                    }
                } else if ip.action == "display" {
                    // Display
                    ip.action = "forward".into();
                    let mut builder = ip.init_root::<js_create::Builder>();
                    builder.set_html(&format!("css;{}-{};display;inline", place, self.name));
                    // Hidden if already a visible
                    match self.portal.actual {
                        Some(ref actual) => {
                            let mut ip = IP::new();
                            ip.action = "forward".into();
                            {
                                let mut builder = ip.init_root::<js_create::Builder>();
                                builder.set_html(&format!("css;{}-{};display;none", actual, self.name));
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
