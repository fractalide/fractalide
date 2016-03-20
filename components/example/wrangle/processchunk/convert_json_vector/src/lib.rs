
extern crate capnp;
#[macro_use]
extern crate rustfbp;
extern crate rustc_serialize;

mod contract_capnp {
    include!("value_string.rs");
    include!("list_tuple.rs");
}
use contract_capnp::value_string;
use contract_capnp::list_tuple;

use rustc_serialize::json;

#[derive(RustcDecodable)]
pub struct Item {
    thetype: String,
    amount: i64,
}
#[derive(RustcDecodable)]
struct Purchases {
    purchases: Vec<Item>,
}

component! {
    example_wrangle_processchunk_convert_json_vector,
    inputs(input: value_string),
    inputs_array(),
    outputs(output: list_tuple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let value = try!(ip.get_reader());
        let value: value_string::Reader = try!(value.get_root());
        let value = try!(value.get_value());
        if value != "end" {
            if value.contains("type") {
                let purchases: Purchases = json::decode(value.replace("type", "thetype").as_str()).unwrap();
                let purchases = Purchases {purchases:  purchases.purchases};
                let mut new_ip = capnp::message::Builder::new_default();
                {
                    let ip = new_ip.init_root::<list_tuple::Builder>();
                    let mut tuples = ip.init_tuples(purchases.purchases.len() as u32);
                    let mut i: u32 = 0;
                    for tuple in &purchases.purchases {
                        tuples.borrow().get(i).set_first(tuple.thetype.as_str());
                        tuples.borrow().get(i).set_second(format!("{}",tuple.amount).as_str());
                        i += 1;
                    }
                }
                let mut send_ip = IP::new();
                try!(send_ip.write_builder(&new_ip));
                try!(self.ports.send("output", send_ip));
            }else {
                let mut empty_ip = capnp::message::Builder::new_default();
                {
                    let ip = empty_ip.init_root::<list_tuple::Builder>();
                    let mut tuples = ip.init_tuples(1);
                    tuples.borrow().get(0).set_first("zero");
                    tuples.borrow().get(0).set_second("0");
                }
                let mut send_ip = IP::new();
                try!(send_ip.write_builder(&empty_ip));
                try!(self.ports.send("output", send_ip));
            }
        } else {
            let mut end_ip = capnp::message::Builder::new_default();
            {
                let ip = end_ip.init_root::<list_tuple::Builder>();
                let mut tuples = ip.init_tuples(1);
                tuples.borrow().get(0).set_first("end");
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&end_ip));
            try!(self.ports.send("output", send_ip));
        }
        Ok(())
    }
}

