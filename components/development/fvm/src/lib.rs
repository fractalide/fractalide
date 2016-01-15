#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

extern crate capnp;

mod contract_capnp {
    include!("fbp_semantic_error.rs");
    include!("file_error.rs");
}
use contract_capnp::semantic_error;
use contract_capnp::file_error;

component! {
    fvm,
    inputs(file_error: file_error, semantic_error: fbp_semantic_error),
    inputs_array(),
    outputs(),
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
                    println!("{}", parsing.get(i).unwrap());
                }
            }
            _ => {}
        };
        match self.ports.try_recv("file_error".into()) {
            Ok(mut ip) => {
                let error = ip.get_reader().expect("fbp_print_graph : cannot get reader");
                let error: file_error::Reader = error.get_root().expect("fbp_print_graph : not a literal");
                println!("File not exist at : {}", error.get_not_found().unwrap());
            }
            _ => {}
        };
    }
}
