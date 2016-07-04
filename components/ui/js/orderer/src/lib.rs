extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_orderer, contracts(js_create)
    inputs(),
    inputs_array(places: any),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(), portal(Vec<String> => Vec::new())
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
                            if self.portal.contains(&place) {
                                action = Some("forward_create".to_string());
                                format!("html;{}-{};{}", place, self.name, html)
                            } else {
                                action = Some("insert_content".to_string());
                                let n_html = format!("<div id=\"{}-{}\" style=\"order:{};{}\">{}</div>", place, self.name, place, div_style, html);
                                self.portal.push(place.into());
                                n_html
                            }
                        };
                        builder.set_html(&new_html);
                    }
                    ip.action = action.expect("unreachable");
                } else if ip.action == "delete" {
                    let pos = self.portal.iter()
                        .position(|el| el.as_str() == place)
                        .expect("unreachable");
                    self.portal.remove(pos);
                    ip.action = "forward".into();
                    {
                        let mut builder = ip.init_root::<js_create::Builder>();
                        builder.set_html(&format!("delete;{}-{};", place, self.name))
                    }
                }
                try!(self.ports.send("output", ip));
            }
        }

        Ok(())
    }
}
