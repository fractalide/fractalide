extern crate capnp;
#[macro_use]
extern crate rustfbp;
mod contracts {
    include!("net_ndn_interest.rs");
    include!("net_ndn_data.rs");
}
use self::contracts::net_ndn_interest;
use self::contracts::net_ndn_data;

component! {
    ContentStore,
    inputs(lookup_interest: net_ndn_interest
        , cache_data: net_ndn_data),
    inputs_array(),
    outputs( interest_miss: net_ndn_interest),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut cs: HashMap<String, String> = HashMap::new();
        loop {
            match self.ports.try_recv("cache_data") {
                Ok(mut ip) => {
                    let data_reader = try!(ip.get_reader());
                    let data_reader: net_ndn_data::Reader = try!(data_reader.get_root());
                    cs.insert(try!(data_reader.get_name()).into(), try!(data_reader.get_content()).into());
                }
                _ => {}
            };
            match self.ports.try_recv("lookup_interest") {
                Ok(mut ip) => {
                    let interest_reader = try!(ip.get_reader());
                    let interest_reader: net_ndn_interest::Reader = try!(interest_reader.get_root());
                    if cs.contains_key(try!(interest_reader.get_name())) {
                        try!(self.ports.send("interest_hit", ip.clone()));
                        println!("CS interest_hit");
                    }
                    else {
                        try!(self.ports.send("interest_miss", ip.clone()));
                        println!("CS interest_miss");
                    }
                }
                _ => {}
            };
        }
        Ok(())
    }
}
