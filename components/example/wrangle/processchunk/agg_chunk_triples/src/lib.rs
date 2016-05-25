#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::str::FromStr;

component! {
    example_wrangle_process_agg_chunk_triples, contracts(list_triple, value_string)
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: list_triple, next : value_string),
    outputs_array(),
    option(),
    acc(list_triple),
    fn run(&mut self) -> Result<()> {
        loop{
            let mut ip = try!(self.ports.recv("input"));
            let input_triple: list_triple::Reader = try!(ip.get_root());
            let input_triple = try!(input_triple.get_triples());
            if try!(input_triple.get(0).get_first()) == "end" {
                let mut ip_acc = try!(self.ports.recv("acc"));
                let acc_reader: list_triple::Reader = try!(ip_acc.get_root());
                let acc_triple = try!(acc_reader.get_triples());
                let mut feedback_ip = IP::new();
                {
                    let ip = feedback_ip.init_root::<list_triple::Builder>();
                    let mut feedback_list = ip.init_triples(acc_triple.len() as u32);
                    let first = try!(acc_triple.get(0).get_first());
                    for i in 0..feedback_list.len() {
                        feedback_list.borrow().get(i).set_first(first);
                        feedback_list.borrow().get(i).set_second(try!(acc_triple.get(i).get_second()));
                        feedback_list.borrow().get(i).set_third(format!("{}", try!(acc_triple.get(i).get_third())).as_str());
                    }
                }
                try!(self.ports.send("output", feedback_ip));
                break;
            } else {
                let mut ip_acc = try!(self.ports.recv("acc"));
                let acc_reader: list_triple::Reader = try!(ip_acc.get_root());
                let acc_triple = try!(acc_reader.get_triples());
                let acc_length = acc_triple.len() as u32;
                let input_length = input_triple.len() as u32;
                if acc_length == 0 {
                    let mut acc_ip = IP::new();
                    {
                        let ip = acc_ip.init_root::<list_triple::Builder>();
                        let mut acc_triple = ip.init_triples(input_length);
                        for i in 0..input_triple.len() {
                            acc_triple.borrow().get(i).set_first(try!(input_triple.get(i).get_first()));
                            acc_triple.borrow().get(i).set_second(try!(input_triple.get(i).get_second()));
                            acc_triple.borrow().get(i).set_third(try!(input_triple.get(i).get_third()));
                        }
                    }
                    try!(self.ports.send("acc", acc_ip));
                }else {
                    let mut medium_sized_bean_counter = HashMap::new();
                    for i in 0..input_triple.len() {
                        let first = try!(input_triple.get(i).get_first());
                        let second = try!(input_triple.get(i).get_second());
                        let third = try!(input_triple.get(i).get_third());
                        if second.is_empty() || second == "0" {
                            continue;
                        } else {
                            let bean = medium_sized_bean_counter.entry(second).or_insert(0);
                            *bean += i32::from_str(third).unwrap();
                        }
                    }
                    for i in 0..acc_triple.len() {
                        let first = try!(acc_triple.get(i).get_first());
                        let second = try!(acc_triple.get(i).get_second());
                        let third = try!(acc_triple.get(i).get_third());
                        if second.is_empty() || second == "0" {
                            continue;
                        } else {
                            let bean = medium_sized_bean_counter.entry(second).or_insert(0);
                            *bean += i32::from_str(third).unwrap();
                        }
                    }
                    let mut new_acc_ip = IP::new();
                    {
                        let ip = new_acc_ip.init_root::<list_triple::Builder>();
                        let mut new_acc_triple = ip.init_triples(medium_sized_bean_counter.len() as u32);
                        let first = try!(acc_triple.get(0).get_first());
                        let mut i :u32 = 0;
                        for (key,val) in medium_sized_bean_counter.iter() {
                            new_acc_triple.borrow().get(i).set_first(first);
                            new_acc_triple.borrow().get(i).set_second(key);
                            new_acc_triple.borrow().get(i).set_third(format!("{}",val).as_str());
                            i += 1;
                        }
                    }
                    try!(self.ports.send("acc", new_acc_ip));
                }
            }
            let mut next_ip = IP::new();
            {
                let mut ip = next_ip.init_root::<value_string::Builder>();
                ip.set_value("next");
            }
            try!(self.ports.send("next", next_ip));
        }
        Ok(())
    }
}
