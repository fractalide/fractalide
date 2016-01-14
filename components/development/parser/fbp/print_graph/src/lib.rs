#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

extern crate capnp;

mod contract_capnp {
    include!("fbp_graph.rs");
}
use contract_capnp::graph;

component! {
    fbp_print_graph,
    inputs(input: fbp_graph),
    inputs_array(),
    outputs(output: fbp_graph),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {
        let mut ip = self.ports.recv("input".into()).expect("fbp_print_graph : unable to receive");
        let graph = ip.get_reader().expect("fbp_print_graph : cannot get reader");
        let graph: graph::Reader = graph.get_root().expect("fbp_print_graph : not a literal");

        println!("nodes :");
        for n in graph.get_nodes().unwrap().iter() {
            println!("  {}({})", n.get_name().unwrap(), n.get_sort().unwrap());
        }
        println!("\nedges :");
        for n in graph.get_edges().unwrap().iter() {
            println!("  {}() {}[{}] -> {}[{}] {}()", n.get_o_name().unwrap(), n.get_o_port().unwrap(),
                     n.get_o_selection().unwrap(), n.get_i_port().unwrap(),
                     n.get_i_selection().unwrap(), n.get_i_name().unwrap());
        }
        println!("\niips :");
        for n in graph.get_iips().unwrap().iter() {
            println!("  '{}' -> {}[{}] {}()", n.get_iip().unwrap(), n.get_comp().unwrap(),
                     n.get_port().unwrap(), n.get_selection().unwrap());
        }
        println!("\nexternal inputs :");
        for n in graph.get_external_inputs().unwrap().iter() {
            println!("  {} => {}[{}] {}()", n.get_name().unwrap(), n.get_port().unwrap(),
                     n.get_selection().unwrap(), n.get_comp().unwrap());
        }
        println!("\nexternal outputs :");
        for n in graph.get_external_outputs().unwrap().iter() {
            println!("  {}() {}[{}] => {}", n.get_comp().unwrap(), n.get_port().unwrap(),
                     n.get_selection().unwrap(), n.get_name().unwrap());
        }


        let _ = self.ports.send("output".into(), ip);
    }
}
