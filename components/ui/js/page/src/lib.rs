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
        new_ip.before_send().expect("cannot before send");
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
                    let mut reader: js_create::Reader = try!(ip.get_root());
                    out.send(format!("insert;main;{}", try!(reader.get_html())));
                },
                "forward_create" => {
                    let mut reader: js_create::Reader = try!(ip.get_root());
                    let name = try!(reader.get_name());
                    let ptr = reader.get_sender();
                    if name.len() > 0 {
                        let sender: Box<IPSender> = unsafe { Box::from_raw(ptr as *mut IPSender) };
                        senders.insert(name.into(), sender);
                    }
                    out.send(try!(reader.get_html()));
                },
                "delete" => {
                    out.send("html;main;");
                }
                "forward" => {
                    let mut reader: js_create::Reader = try!(ip.get_root());
                    out.send(try!(reader.get_html()));
                }
                "intern_msg" => {
                    let mut reader: generic_text::Reader = try!(ip.get_root());
                    let text = try!(reader.get_text());
                    let pos = try!(text.find("#").ok_or(result::Error::Misc("bad response from page".into())));
                    let (a, b) = text.split_at(pos);
                    let (_, b) = b.split_at(1);
                    if senders.contains_key(a) {
                        let s = senders.get(a).expect("unreachable");
                        let mut ip = IP::new();
                        ip.action = b.into();
                        try!(s.send(ip));
                    }
                },
                _ => {
                    println!("Receive a random ip : {}", act);
                }


            }
        }

        handle.join().expect("cannot join");

        Ok(())
    }
}
