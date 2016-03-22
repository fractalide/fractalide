extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("quadruple.rs");
}
use contract_capnp::quadruple;


fn print_data(ip: rustfbp::ports::IP)  -> Result<(String,String,String,String)>
{
    let data_reader = try!(ip.get_reader());
    let data: quadruple::Reader = try!(data_reader.get_root());
    let min = data.get_first().to_string();
    let max =  data.get_second().to_string();
    let average =  data.get_third().to_string();
    let median = data.get_fourth().to_string();
    Ok((min.clone(),max.clone(),average.clone(),median.clone()))
}

component! {
    example_wrangle_stats,
    inputs(raw: quadruple, anonymous: quadruple),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let (min, max, average, median): (String, String, String, String) = try!(print_data(try!(self.ports.recv("raw"))));
        println!("raw: min: {}, max: {}, average: {}, median: {}", min, max, average, median);
        let (min, max, average, median): (String, String, String, String) = try!(print_data(try!(self.ports.recv("anonymous"))));
        println!("anonymous: min: {}, max: {}, average: {}, median: {}", min, max, average, median);
        Ok(())
    }
}

