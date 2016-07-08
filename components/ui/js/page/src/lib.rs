extern crate capnp;
extern crate ws;

#[macro_use]
extern crate rustfbp;

use ws::{listen, Handler, Message, Handshake, CloseCode};
use std::thread;
use std::sync::mpsc::channel;

struct Server {
    out: ws::Sender,
    input: IPSender,
}

impl Handler for Server {
    fn on_message(&mut self, msg: Message) -> ws::Result<()> {
        let mut new_ip = IP::new();
        new_ip.action = "intern_msg".into();
        {
            let mut builder = new_ip.init_root::<generic_text::Builder>();
            let msg = try!(msg.as_text());
            builder.set_text(msg);
        }
        &self.input.send(new_ip).expect("cannot send intern");
        Ok(())
    }

    fn on_close(&mut self, code: CloseCode, reason: &str) {
        // The WebSocket protocol allows for a utf8 reason for the closing state after the
        // close code. WS-RS will attempt to interpret this data as a utf8 description of the
        // reason for closing the connection. I many cases, `reason` will be an empty string.
        // So, you may not normally want to display `reason` to the user,
        // but let's assume that we know that `reason` is human-readable.
        match code {
            CloseCode::Normal => println!("The client is done with the connection."),
            CloseCode::Away   => println!("The client is leaving the site."),
            _ => println!("The client encountered an error: {}", reason),
        }
    }
}

component! {
    ui_js_page, contracts(generic_text, js_create)
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let (s, r) = channel();
        let in_sender = self.ports.get_sender("input").expect("cannot find input");

        let handle = thread::spawn(move || {
            listen("127.0.0.1:3012", move |out| {
                s.send(out.clone()).expect("cannot send");
                Server {
                    out: out,
                    input: in_sender.clone(),
                }
            });
        });

        let mut out = try!(r.recv());
        let mut senders: HashMap<String, Box<IPSender>> = HashMap::new();

        loop {
            let mut ip = try!(self.ports.recv("input"));
            let act = ip.action.clone();
            match &act[..] {
                "create" => {
                    // Add append to main
                    {
                        let mut builder = try!(ip.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                        builder.set_append("main");
                    }
                    try!(ip.before_send());
                    // Save the sender
                    {
                        let mut reader: js_create::Reader = try!(ip.get_root());
                        let name = try!(reader.get_name());
                        let ptr = reader.get_sender();
                        if name.len() > 0 {
                            let sender: Box<IPSender> = unsafe { Box::from_raw(ptr as *mut IPSender) };
                            senders.insert(name.into(), sender);
                        }
                    }
                    // Create d3
                    let d3 = try!(create_d3(ip));
                    out.send(d3);
                },
                "forward_create" => {
                    {
                        let mut reader: js_create::Reader = try!(ip.get_root());
                        let name = try!(reader.get_name());
                        let ptr = reader.get_sender();
                        if name.len() > 0 {
                            let sender: Box<IPSender> = unsafe { Box::from_raw(ptr as *mut IPSender) };
                            senders.insert(name.into(), sender);
                        }
                    }
                    let d3 = try!(create_d3(ip));
                    out.send(d3);
                },
                // "delete" => {
                //     out.send("html;main;");
                // }
                "forward" => {
                    let d3 = try!(create_d3(ip));
                    out.send(d3);
                }
                "intern_msg" => {
                    let mut reader: generic_text::Reader = try!(ip.get_root());
                    let text = try!(reader.get_text());
                    let pos = try!(text.find("#").ok_or(result::Error::Misc("bad response from page".into())));
                    let (action, id) = text.split_at(pos);
                    let (_, id) = id.split_at(1);
                    let mut ip = IP::new();
                    ip.action = action.into();
                    let id = if action == "input" {
                        let pos = try!(id.find("#").ok_or(result::Error::Misc("bad response from page".into())));
                        let (id, text) = id.split_at(pos);
                        let (_, text) = text.split_at(1);
                        {
                            let mut builder: generic_text::Builder = ip.init_root();
                            builder.set_text(text);
                        }
                        id
                    } else if action == "keyup" {
                        let pos = try!(id.find("#").ok_or(result::Error::Misc("bad response from page".into())));
                        let (id, text) = id.split_at(pos);
                        let (_, text) = text.split_at(1);
                        {
                            let mut builder: generic_text::Builder = ip.init_root();
                            builder.set_text(text);
                        }
                        id
                    } else {
                        id
                    };
                    if senders.contains_key(id) {
                        let s = senders.get(id).expect("unreachable");
                        try!(s.send(ip));
                    }
                },
                _ => {
                    println!("Receive a random ip : {}", act);
                    self.ports.send_action("output", ip);
                }


            }
        }

        handle.join().expect("cannot join");

        Ok(())
    }
}

fn create_d3(mut ip: IP) -> Result<String> {
    let mut reader: js_create::Reader = try!(ip.get_root());
    // Manage name and sender
    let mut d3 = "d3.select(\"#".to_string();
    // Two possibilities : append is set, so add to the parent. append is not send, select the name
    if reader.has_append() {
        d3.push_str(try!(reader.get_append()));
        d3.push_str("\").append(\"");
        d3.push_str(try!(reader.get_type()));
        d3.push_str("\").attr(\"id\", \"");
        d3.push_str(try!(reader.get_name()));
        d3.push_str("\")");
    } else {
        d3.push_str(try!(reader.get_name()));
        d3.push_str("\")");
    }

    if reader.get_remove() {
        d3.push_str(".remove();");
        return Ok(d3);
    }

    let text = try!(reader.get_text());
    if text != "" {
        d3.push_str(".text(\"");
        d3.push_str(text);
        d3.push_str("\")");
    }

    for attr in try!(reader.get_attr()).iter() {
        d3.push_str(".attr(\"");
        d3.push_str(try!(attr.get_key()));
        d3.push_str("\", \"");
        d3.push_str(try!(attr.get_val()));
        d3.push_str("\")");
    }
    for class in try!(reader.get_class()).iter() {
        d3.push_str(".classed(\"");
        d3.push_str(try!(class.get_name()));
        d3.push_str("\",");
        if class.get_set() {
            d3.push_str("true");
        } else {
            d3.push_str("false");
        }
        d3.push_str(")");
    }
    for style in try!(reader.get_style()).iter() {
        d3.push_str(".style(\"");
        d3.push_str(try!(style.get_key()));
        d3.push_str("\", \"");
        d3.push_str(try!(style.get_val()));
        d3.push_str("\")");
    }
    for property in try!(reader.get_property()).iter() {
        d3.push_str(".property(\"");
        d3.push_str(try!(property.get_key()));
        d3.push_str("\", \"");
        d3.push_str(try!(property.get_val()));
        d3.push_str("\")");
    }
    d3.push_str(";");
    Ok(d3)
}
