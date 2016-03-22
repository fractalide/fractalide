extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("list_tuple.rs");
    include!("value_string.rs");
    include!("list_triple.rs");

}
use contract_capnp::list_tuple;
use contract_capnp::list_triple;
use contract_capnp::value_string;

component! {
    DtVectorExtractKeyValue,
    inputs(input: list_tuple),
    inputs_array(),
    outputs(output: list_tuple),
    outputs_array(),
    option(value_string),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        let extract_key = try!(opt.get_reader());
        let extract_key: value_string::Reader = try!(extract_key.get_root());

        let mut ip = try!(self.ports.recv("input"));
        let list_tuple = try!(ip.get_reader());
        let list_tuple: list_tuple::Reader = try!(list_tuple.get_root());
        let list_tuple = try!(list_tuple.get_tuples());

        if try!(list_tuple.get(0).get_first()) != "end" {
            let mut small_sized_bean_counter = HashMap::new();
            for i in 0..list_tuple.len()
            {
                if try!(list_tuple.get(i).get_first()) == try!(extract_key.get_value()) {
                    let bean = small_sized_bean_counter.entry(try!(list_tuple.get(i).get_second())).or_insert(0);
                    *bean += 1;
                }
            }
            if small_sized_bean_counter.len() == 0 {
                small_sized_bean_counter.insert("0",0);
            }
            let mut new_ip = capnp::message::Builder::new_default();
            {
                let ip = new_ip.init_root::<list_triple::Builder>();
                let mut triples = ip.init_triples(small_sized_bean_counter.len() as u32);
                let mut i: u32 = 0;
                for (key, val) in small_sized_bean_counter.iter() {
                    triples.borrow().get(i).set_first(try!(extract_key.get_value()));
                    triples.borrow().get(i).set_second(format!("{}",key).as_str());
                    triples.borrow().get(i).set_third(format!("{}",val).as_str());
                    i += 1;
                }
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&new_ip));
            try!(self.ports.send("output", send_ip));
        } else {
            let mut end_ip = capnp::message::Builder::new_default();
            {
                let ip = end_ip.init_root::<list_triple::Builder>();
                let mut triples = ip.init_triples(1);
                triples.borrow().get(0).set_first("end");
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&end_ip));
            try!(self.ports.send("output", send_ip));
        }
        Ok(())
    }
}
