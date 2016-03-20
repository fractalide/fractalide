#![feature(custom_derive, plugin)]
#![plugin(serde_macros)]

extern crate capnp;

#[macro_use]
extern crate rustfbp;

extern crate serde;
extern crate serde_json;

mod contracts {
    include!("file_desc.rs");
    include!("key_value.rs");

}
use contracts::file_desc;
use contracts::key_value;

#[derive(Debug, PartialEq, Serialize, Deserialize)]
pub struct Item {
    #[serde(rename="type")]
    type_: String, // TODO make generic
    amount: i64, // TODO make generic
}

#[derive(Debug, PartialEq, Serialize, Deserialize)]
struct Vector {
    purchases: Vec<Item>, // TODO make generic
}

component! {
    clone,
    inputs(input: file_desc),
    inputs_array(),
    outputs(output: key_value),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let file = try!(ip.get_reader());
        let file: file_desc::Reader = try!(file.get_root());
        match try!(file.which()) {
            file_desc::Start(_) => {},
            file_desc::Text(raw_json) => {
                let raw_json = try!(raw_json);
                let Vector { purchases: items } = serde_json::from_str(&raw_json).unwrap();
                for item in items {
                    let Item { type_: key, amount: value} = item;
                    let mut new_ip = capnp::message::Builder::new_default();
                    {
                        let mut ip = new_ip.init_root::<key_value::Builder>();
                        ip.set_key(key.as_str());
                        ip.set_value(value);
                    }
                    let mut send_ip = IP::new();
                    try!(send_ip.write_builder(&new_ip));
                    try!(self.ports.send("output", send_ip));
                }
                let mut new_ip = capnp::message::Builder::new_default();
                {
                    let mut ip = new_ip.init_root::<key_value::Builder>();
                    ip.set_key("end");
                    ip.set_value(0);
                }
                let mut end_ip = IP::new();
                try!(end_ip.write_builder(&new_ip));
                try!(self.ports.send("output", end_ip));
            },
            file_desc::End(_) => {},
        }
        Ok(())
    }
}
