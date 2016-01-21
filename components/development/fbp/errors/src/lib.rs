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
    fn run(&mut self) {

        match self.ports.try_recv("semantic_error".into()) {
            Ok(mut ip) => {
                let error = ip.get_reader().expect("fbp_print_graph : cannot get reader");
                let error: semantic_error::Reader = error.get_root().expect("fbp_print_graph : not a literal");

                println!("Graph at : {}", error.get_path().unwrap());
                let parsing = error.get_parsing().unwrap();
                for i in 0..parsing.len() {
                    println!("  {}", parsing.get(i).unwrap());
                }
                println!("");
            }
            _ => {}
        };

        match self.ports.try_recv("file_error".into()) {
            Ok(mut ip) => {
                let error = ip.get_reader().expect("fbp_print_graph : cannot get reader");
                let error: file_error::Reader = error.get_root().expect("fbp_print_graph : not a literal");
                println!("Subnet not exist at : {}\n", error.get_not_found().unwrap());
            }
            _ => {}
        };


        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<graph::Builder>();
            ip.set_path("error");
        }
        let mut send_ip = self.allocator.ip.build_empty();
        send_ip.write_builder(&new_ip).expect("fbp_lexical: cannot write");
        let _ = self.ports.send("output".into(), send_ip);
    }
}
