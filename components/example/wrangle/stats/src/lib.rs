#![feature(btree_range, collections_bound)]
extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_triple.rs");
    include!("quadruple.rs");
}
use contract_capnp::list_triple;
use contract_capnp::quadruple;
use std::collections::BTreeSet;
use std::collections::Bound::{Included, Unbounded, Excluded};
use std::str::FromStr;

fn process_data(ip: rustfbp::ports::IP) -> Result<(u32,u32,u32,u32)>
{
    let data_reader = try!(ip.get_reader());
    let data_reader: list_triple::Reader = try!(data_reader.get_root());
    let data = try!(data_reader.get_triples());
    let first = try!(data.get(0).get_second());
    let stats_length = data.len();
    let mut total :u32 = 0;
    let mut stats = BTreeSet::new();
    for i in 0..data.len() {
        let second = try!(data.get(i).get_second());
        let third = try!(data.get(i).get_third());
        let second = u32::from_str(second).unwrap();
        stats.insert(second);
        total += second;
    }
    let min =  stats.iter().next().unwrap();
    let max =  stats.iter().last().unwrap();
    let average :u32 = total / stats.len() as u32;
    let mid_top = stats.range(Included(&average), Unbounded).next();
    let mid_bottom = stats.range(Unbounded,Included(&average)).last();
    let median :u32 = (mid_top.unwrap() + mid_bottom.unwrap()) / 2;
    Ok((min.clone(),max.clone(),average.clone(),median.clone()))
}

component! {
    example_wrangle_stats,
    inputs(raw: list_triple, anonymous: list_triple),
    inputs_array(),
    outputs(raw: quadruple, anonymous: quadruple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let (min, max, average, median): (u32, u32, u32, u32) = try!(process_data(try!(self.ports.recv("raw"))));
        let mut raw_ip = capnp::message::Builder::new_default();
        {
            let mut quad = raw_ip.init_root::<quadruple::Builder>();
            quad.set_first(min);
            quad.set_second(max);
            quad.set_third(average);
            quad.set_fourth(median);
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&raw_ip));
        try!(self.ports.send("raw", send_ip));

        let (min, max, average, median): (u32, u32, u32, u32) = try!(process_data(try!(self.ports.recv("anonymous"))));
        let mut anonymous_ip = capnp::message::Builder::new_default();
        {
            let mut quad = anonymous_ip.init_root::<quadruple::Builder>();
            quad.set_first(min);
            quad.set_second(max);
            quad.set_third(average);
            quad.set_fourth(median);
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&anonymous_ip));
        try!(self.ports.send("anonymous", send_ip));
        Ok(())
    }
}

