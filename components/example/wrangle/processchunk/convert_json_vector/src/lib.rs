#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate rustc_serialize;

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
    example_wrangle_processchunk_convert_json_vector, contracts(value_string, list_tuple)
    inputs(input: value_string),
    inputs_array(),
    outputs(output: list_tuple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let value: value_string::Reader = try!(ip.get_root());
        let value = try!(value.get_value());
        if value != "end" {
            if value.contains("type") {
                let purchases: Purchases = json::decode(value.replace("type", "thetype").as_str()).unwrap();
                let purchases = Purchases {purchases:  purchases.purchases};
                let mut new_ip = IP::new();
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
                try!(self.ports.send("output", new_ip));
            }else {
                let mut empty_ip = IP::new();
                {
                    let ip = empty_ip.init_root::<list_tuple::Builder>();
                    let mut tuples = ip.init_tuples(1);
                    tuples.borrow().get(0).set_first("zero");
                    tuples.borrow().get(0).set_second("0");
                }
                try!(self.ports.send("output", empty_ip));
            }
        } else {
            let mut end_ip = IP::new();
            {
                let ip = end_ip.init_root::<list_tuple::Builder>();
                let mut tuples = ip.init_tuples(1);
                tuples.borrow().get(0).set_first("end");
            }
            try!(self.ports.send("output", end_ip));
        }
        Ok(())
    }
}
