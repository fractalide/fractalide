#[macro_use]
extern crate rustfbp;

extern crate capnp;

use std::fs;

mod contract_capnp {
    include!("fbp_graph.rs");
    include!("fbp_semantic_error.rs");
    include!("file_error.rs");
}
use contract_capnp::graph;
use contract_capnp::file_error;
use contract_capnp::semantic_error;

component! {
    fvm,
    inputs(file_error: file_error, semantic_error: semantic_error),
    inputs_array(),
    outputs(output: graph),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()>{

        match self.ports.try_recv("semantic_error") {
            Ok(mut ip) => {
                let error = try!(ip.get_reader());
                let error: semantic_error::Reader = try!(error.get_root());

                println!("Graph at : {}", try!(error.get_path()));
                let parsing = try!(error.get_parsing());
                for i in 0..parsing.len() {
                    println!("  {}", try!(parsing.get(i)));
                }
                println!("");
            }
            _ => {}
        };

        match self.ports.try_recv("file_error") {
            Ok(mut ip) => {
                let error = try!(ip.get_reader());
                let error: file_error::Reader = try!(error.get_root());
                println!("Subnet not exist at : {}\n", try!(error.get_not_found()));
            }
            _ => {}
        };


        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<graph::Builder>();
            ip.set_path("error");
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&new_ip));
        let _ = self.ports.send("output", send_ip);
        Ok(())
    }
}
