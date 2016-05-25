#![feature(btree_range, collections_bound)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::collections::BTreeSet;
use std::collections::Bound::{Included, Unbounded, Excluded};
use std::str::FromStr;

fn process_data(mut ip: rustfbp::ports::IP) -> Result<(u32,u32,u32,f32)>
{
    let data_reader: list_triple::Reader = try!(ip.get_root());
    let data = try!(data_reader.get_triples());
    let stats_length = data.len();
    let mut total :u32 = 0;
    let mut stats = BTreeSet::new();
    for i in 0..data.len() {
        let second = u32::from_str(try!(data.get(i).get_second())).unwrap();
        stats.insert(second);
        total += second;
    }
    let min =  stats.iter().next().unwrap();
    let max =  stats.iter().last().unwrap();
    let average :u32 = total / stats.len() as u32;
    let median :f32 = if stats.len() as f32 % 2 as f32 != 0 as f32{
        let mid :f32 = stats.len() as f32 / 2 as f32;
        let floor = mid.floor();
        let ceil = mid.ceil();
        let floor_val = stats.iter().nth(floor as usize).unwrap().clone();
        let ceil_val = stats.iter().nth(ceil as usize).unwrap().clone();
        floor_val as f32 + ceil_val as f32 / 2 as f32
    } else {
        stats.iter().nth(stats.len()/2).unwrap().clone() as f32
    };
    Ok((min.clone(),max.clone(),average.clone(),median.clone()))
}

component! {
    example_wrangle_stats, contracts(list_triple, quadruple)
    inputs(raw: list_triple, anonymous: list_triple),
    inputs_array(),
    outputs(raw: quadruple, anonymous: quadruple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let (min, max, average, median): (u32, u32, u32, f32) = try!(process_data(try!(self.ports.recv("raw"))));
        let mut raw_ip = IP::new();
        {
            let mut quad = raw_ip.init_root::<quadruple::Builder>();
            quad.set_first(min);
            quad.set_second(max);
            quad.set_third(average);
            quad.set_fourth(median);
        }
        try!(self.ports.send("raw", raw_ip));

        let (min, max, average, median): (u32, u32, u32, f32) = try!(process_data(try!(self.ports.recv("anonymous"))));
        let mut anonymous_ip = IP::new();
        {
            let mut quad = anonymous_ip.init_root::<quadruple::Builder>();
            quad.set_first(min);
            quad.set_second(max);
            quad.set_third(average);
            quad.set_fourth(median);
        }
        try!(self.ports.send("anonymous", anonymous_ip));
        Ok(())
    }
}
