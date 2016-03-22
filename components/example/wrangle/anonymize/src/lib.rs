extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_triple.rs");
}
use contract_capnp::list_triple;
use std::str::FromStr;

component! {
    example_wrangle_anonymize,
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: list_triple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let ip = try!(self.ports.recv("input"));
        let anon_reader = try!(ip.get_reader());
        let anon_reader: list_triple::Reader = try!(anon_reader.get_root());
        let to_anon_triple = try!(anon_reader.get_triples());

        let mut anonymized_bean_counter = HashMap::new();
        let first = try!(to_anon_triple.get(0).get_first());
        for i in 0..to_anon_triple.len() {
            let second = try!(to_anon_triple.get(i).get_second());
            let third = try!(to_anon_triple.get(i).get_third());
            if i32::from_str(third).unwrap() < 6 {
                continue;
            }
            anonymized_bean_counter.insert(second, third);
        }
        let mut fin_ip = capnp::message::Builder::new_default();
        {
            let ip = fin_ip.init_root::<list_triple::Builder>();
            let mut fin_triple = ip.init_triples(anonymized_bean_counter.len() as u32);
            let mut i :u32 = 0;
            for (key,val) in anonymized_bean_counter.iter() {
                fin_triple.borrow().get(i).set_first(first);
                fin_triple.borrow().get(i).set_second(key);
                fin_triple.borrow().get(i).set_third(format!("{}",val).as_str());
                i += 1;
            }
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&fin_ip));
        try!(self.ports.send("output", send_ip));
        Ok(())
    }
}

