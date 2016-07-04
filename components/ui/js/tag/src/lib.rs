extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

pub struct Portal {
    ty: Option<String>,
    content: Option<String>,
    css: HashMap<String, String>,
    block_css: HashMap<String, String>,
    attributes: HashMap<String, String>,
    buffer: Vec<IP>,
}

impl Portal {
    fn new() -> Self {
        Portal {
            ty: None,
            content: None,
            css: HashMap::new(),
            block_css: HashMap::new(),
            attributes: HashMap::new(),
            buffer: Vec::new(),
        }
    }

    fn clear(&mut self) {
        self.ty = None;
        self.content = None;
        self.css.clear();
        self.block_css.clear();
        self.attributes.clear();
    }

    fn build(&mut self, ip_input: &mut IP) -> Result<()> {
        self.clear();
        let reader: js_tag::Reader = try!(ip_input.get_root());
        let ty = try!(reader.get_type());
        self.ty = Some(ty.into());
        let content = try!(reader.get_content());
        if content != "" {
            self.content = Some(content.into());
        }
        let mut style = "".to_string();
        for css in try!(reader.get_css()).iter() {
            let key = try!(css.get_key());
            let value = try!(css.get_value());
            self.css.insert(key.into(), value.into());
        }
        let mut attributes = "".to_string();
        for css in try!(reader.get_attributes()).iter() {
            let key = try!(css.get_key());
            let value = try!(css.get_value());
            attributes.push_str(key);
            attributes.push_str("=");
            attributes.push_str(value);
            attributes.push_str(" ");
            self.attributes.insert(key.into(), value.into());
        }
        // set upper css
        let mut block_css: String = "".to_string();
        for css in try!(reader.get_block_css()).iter() {
            let key = try!(css.get_key());
            let value = try!(css.get_value());
            block_css.push_str(key);
            block_css.push_str(":");
            block_css.push_str(value);
            block_css.push_str("");
            self.block_css.insert(key.into(), value.into());
        }

        Ok(())
    }
}

component! {
    ui_js_tag, contracts(js_create, js_tag, generic_tuple_text, generic_text)
        inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(), portal(Portal => Portal::new())
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));
        if &ip_input.action != "create" && self.portal.ty.is_none() {
            self.portal.buffer.push(ip_input);
        } else {
            try!(handle_ip(self, ip_input));
        }
        Ok(())
    }
}

pub fn handle_ip(mut comp: &mut ui_js_tag, mut ip_input: IP) -> Result<()> {
    match &ip_input.action[..] {
        "create" => {
            // Put in the portal
            try!(comp.portal.build(&mut ip_input));
            // create the create IP
            let mut ip_create = IP::new();
            ip_create.action = "create".to_string();
            {
                let mut builder = ip_create.init_root::<js_create::Builder>();
                // set the name
                builder.set_name(&comp.name);
                // set the sender (raw ip to the input port)
                let sender = Box::new(try!(comp.ports.get_sender("input")));
                builder.set_sender(Box::into_raw(sender) as u64);

                let mut style = "".to_string();
                for (key, val) in comp.portal.css.iter() {
                    style.push_str(key);
                    style.push_str(":");
                    style.push_str(val);
                    style.push_str(";");
                }
                let mut attributes = "".to_string();
                for (key, val) in comp.portal.attributes.iter() {
                    attributes.push_str(key);
                    attributes.push_str("=\"");
                    attributes.push_str(val);
                    attributes.push_str("\" ");
                }
                let mut block_css = "".to_string();
                for (key, val) in comp.portal.block_css.iter() {
                    block_css.push_str(key);
                    block_css.push_str(":");
                    block_css.push_str(val);
                    block_css.push_str(";");
                }
                // Set the html
                let end = match comp.portal.content {
                    Some(ref content) => {
                        format!(">{}</{}>", content, comp.portal.ty.as_ref().expect("unreachable"))
                    },
                    None => "/>".to_string()
                };
                let html = format!("<{} id=\"{}\" style=\"{}\" {}{}",
                                   comp.portal.ty.as_ref().expect("unreachable"),
                                   comp.name,
                                   style,
                                   attributes,
                                   end);
                builder.set_html(&html);
                builder.set_css(&block_css);
            }
            let _ = comp.ports.send_action("output", ip_create);
            let buffer = comp.portal.buffer.drain(..).collect::<Vec<_>>();
            for ip in buffer {
                try!(handle_ip(&mut comp, ip));
            }
        }
        // CSS
        "set_css" => {
            // Change in portal
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            comp.portal.css.insert(key.into(), value.into());
            // Send outside
            let mut ip = IP::new();
            ip.action = "forward".into();
            {
                let mut builder = ip.init_root::<js_create::Builder>();
                builder.set_html(&format!("css;{};{};{}", comp.name, key, value));
            }
            try!(comp.ports.send_action("output", ip));
        }
        "get_css" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let resp = comp.portal.css.get(value).map(|resp| resp.as_str())
                .unwrap_or("");
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_text::Builder>();
                builder.set_text(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        // Attributes
        "set_attr" => {
            // Change in portal
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            comp.portal.attributes.insert(key.into(), value.into());
            // Send outside
            let mut ip = IP::new();
            ip.action = "forward".into();
            {
                let mut builder = ip.init_root::<js_create::Builder>();
                builder.set_html(&format!("attr;{};{};{}", comp.name, key, value));
            }
            try!(comp.ports.send_action("output", ip));
        }
        "get_attr" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let resp = comp.portal.attributes.get(value).map(|resp| resp.as_str())
                .unwrap_or("");
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_text::Builder>();
                builder.set_text(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        // Content
        "set_content" => {
            let reader = try!(ip_input.get_root::<generic_text::Reader>());
            let new_content = try!(reader.get_text());
            // Change in portal
            comp.portal.content = Some(new_content.to_string());
            // Send new content
            let mut ip = IP::new();
            ip.action = "forward".to_string();
            {
                let mut builder: js_create::Builder = ip.init_root();
                builder.set_html(&format!("html;{};{}",
                                          comp.name,
                                          new_content,
                ));
            }
            comp.ports.send_action("output", ip);
        }
        "insert_content" => {
            ip_input.action = "forward_create".into();
            {
                let mut builder = try!(ip_input.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                let new_html = {
                    let html = {
                        let reader = builder.borrow().as_reader();
                        try!(reader.get_html())
                    };
                    format!("insert;{};{}",
                            comp.name,
                            html)
                };
                builder.set_html(&new_html);
            }
            comp.ports.send_action("output", ip_input);
        }
        "get_content" => {
            let reader = try!(ip_input.get_root::<generic_text::Reader>());
            let key = try!(reader.get_text());
            let resp = comp.portal.content.as_ref().map(|resp| resp.as_str()).unwrap_or("");
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_text::Builder>();
                builder.set_text(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        // Value (for input)
        "get_val" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let resp = comp.portal.attributes.get("value").map(|resp| resp.as_str())
                .unwrap_or("");
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_text::Builder>();
                builder.set_text(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        "set_val" => {
            let new_val = {
                let reader = try!(ip_input.get_root::<generic_text::Reader>());
                try!(reader.get_text()).to_string()
            };
            {
                ip_input.action = "forward".into();
                let mut builder = ip_input.init_root::<js_create::Builder>();
                let html = format!("val;{};{}", comp.name, &new_val);
                builder.set_html(&html);
            }
            let _ = comp.ports.send_action("output", ip_input);

            // Save it
            comp.portal.attributes.insert("value".into(), new_val);
        }
        "input" => {
            {
                let mut reader: generic_text::Reader = try!(ip_input.get_root());
                comp.portal.attributes.insert("value".into(), try!(reader.get_text()).into());
            }
            let _ = comp.ports.send_action("output", ip_input);

        }
        _ => { let _ = comp.ports.send_action("output", ip_input); }
    }

    Ok(())
        
}
