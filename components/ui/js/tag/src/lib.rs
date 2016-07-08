extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

pub struct Portal {
    ty: Option<String>,
    text: Option<String>,
    style: HashMap<String, String>,
    class: HashMap<String, bool>,
    attributes: HashMap<String, String>,
    property: HashMap<String, String>,
    buffer: Vec<IP>,
}

impl Portal {
    fn new() -> Self {
        Portal {
            ty: None,
            text: None,
            style: HashMap::new(),
            class: HashMap::new(),
            attributes: HashMap::new(),
            property: HashMap::new(),
            buffer: Vec::new(),
        }
    }

    fn clear(&mut self) {
        self.ty = None;
        self.text = None;
        self.style.clear();
        self.class.clear();
        self.attributes.clear();
        self.property.clear();
    }

    fn build(&mut self, ip_input: &mut IP) -> Result<()> {
        self.clear();
        let reader: js_create::Reader = try!(ip_input.get_root());
        let ty = try!(reader.get_type());
        self.ty = Some(ty.into());
        let text = try!(reader.get_text());
        if text != "" {
            self.text = Some(text.into());
        }
        for style in try!(reader.get_style()).iter() {
            let key = try!(style.get_key());
            let value = try!(style.get_val());
            self.style.insert(key.into(), value.into());
        }
        for attr in try!(reader.get_attr()).iter() {
            let key = try!(attr.get_key());
            let value = try!(attr.get_val());
            self.attributes.insert(key.into(), value.into());
        }
        for class in try!(reader.get_class()).iter() {
            let name = try!(class.get_name());
            let set = class.get_set();
            self.class.insert(name.into(), set);
        }
        for prop in try!(reader.get_property()).iter() {
            let key = try!(prop.get_key());
            let value = try!(prop.get_val());
            self.property.insert(key.into(), value.into());
        }
        Ok(())
    }
}

component! {
    ui_js_tag, contracts(js_create, generic_tuple_text, generic_text, generic_bool)
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
            {
                let mut builder = try!(ip_input.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                // set the name
                builder.set_name(&comp.name);
                // set the sender (raw ip to the input port)
                let sender = Box::new(try!(comp.ports.get_sender("input")));
                builder.set_sender(Box::into_raw(sender) as u64);
            }
            let _ = comp.ports.send_action("output", ip_input);
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
            comp.portal.style.insert(key.into(), value.into());
            // Send outside
            let mut ip = IP::new();
            ip.action = "forward".into();
            {
                let mut builder = ip.init_root::<js_create::Builder>();
                builder.set_name(&comp.name);
                let mut style = builder.init_style(1);
                style.borrow().get(0).set_key(key);
                style.borrow().get(0).set_val(value);
            }
            try!(comp.ports.send_action("output", ip));
        }
        "get_css" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let resp = comp.portal.style.get(value).map(|resp| resp.as_str())
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
                builder.set_name(&comp.name);
                let mut attr = builder.init_attr(1);
                attr.borrow().get(0).set_key(key);
                attr.borrow().get(0).set_val(value);
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
        // class
        "set_class" => {
            // Change in portal
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let value = if value == "true" { true } else { false };
            comp.portal.class.insert(key.into(), value);
            // Send outside
            let mut ip = IP::new();
            ip.action = "forward".into();
            {
                let mut builder = ip.init_root::<js_create::Builder>();
                builder.set_name(&comp.name);
                let mut class = builder.init_class(1);
                class.borrow().get(0).set_name(key);
                class.borrow().get(0).set_set(value);
            }
            try!(comp.ports.send_action("output", ip));
        }
        "get_class" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let resp = comp.portal.class.get(value).map(|b| b.to_owned()).unwrap_or(false);
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_bool::Builder>();
                builder.set_bool(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        // property
        "set_property" => {
            // Change in portal
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            comp.portal.property.insert(key.into(), value.into());
            // Send outside
            let mut ip = IP::new();
            ip.action = "forward".into();
            {
                let mut builder = ip.init_root::<js_create::Builder>();
                builder.set_name(&comp.name);
                let mut prop = builder.init_property(1);
                prop.borrow().get(0).set_key(key);
                prop.borrow().get(0).set_val(value);
            }
            try!(comp.ports.send_action("output", ip));
        }
        "get_property" => {
            let reader = try!(ip_input.get_root::<generic_tuple_text::Reader>());
            let key = try!(reader.get_key());
            let value = try!(reader.get_value());
            let resp = comp.portal.property.get(value).map(|resp| resp.as_str())
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
        "set_text" => {
            let reader = try!(ip_input.get_root::<generic_text::Reader>());
            let new_content = try!(reader.get_text());
            // Change in portal
            comp.portal.text = Some(new_content.to_string());
            // Send new content
            let mut ip = IP::new();
            ip.action = "forward".to_string();
            {
                let mut builder: js_create::Builder = ip.init_root();
                builder.set_name(&comp.name);
                builder.set_text(new_content);
            }
            comp.ports.send_action("output", ip);
        }
        "insert_text" => {
            ip_input.action = "forward_create".into();
            {
                let mut builder = try!(ip_input.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                builder.set_append(&comp.name);
            }
            comp.ports.send_action("output", ip_input);
        }
        "get_text" => {
            let reader = try!(ip_input.get_root::<generic_text::Reader>());
            let key = try!(reader.get_text());
            let resp = comp.portal.text.as_ref().map(|resp| resp.as_str()).unwrap_or("");
            let mut ip = IP::new();
            {
                let mut builder = ip.init_root::<generic_text::Builder>();
                builder.set_text(resp);
            }
            ip.action = key.to_string();
            let _ = comp.ports.send_action("output", ip);
        }
        "input" => {
            {
                let mut reader: generic_text::Reader = try!(ip_input.get_root());
                comp.portal.property.insert("value".into(), try!(reader.get_text()).into());
            }
            let _ = comp.ports.send_action("output", ip_input);

        }
        "delete" => {
            {
                let mut builder: js_create::Builder = ip_input.init_root();
                builder.set_name(&comp.name);
                builder.set_remove(true);
            }
            ip_input.action = "forward".into();
            let _ = comp.ports.send_action("output", ip_input);
        }
        _ => { let _ = comp.ports.send_action("output", ip_input); }
    }

    Ok(())
}
