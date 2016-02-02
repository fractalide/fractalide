#[macro_use]
extern crate rustfbp;

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
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let graph = try!(ip.get_reader());
        let graph: graph::Reader = try!(graph.get_root());

        println!("Graph at : {}", try!(graph.get_path()));
        println!("nodes :");
        for n in try!(graph.borrow().get_nodes()).iter() {
            println!("  {}({})", try!(n.get_name()), n.get_sort().unwrap());
        }
        println!("\nedges :");
        for n in try!(graph.borrow().get_edges()).iter() {
            println!("  {}() {}[{}] -> {}[{}] {}()", try!(n.get_o_name()), try!(n.get_o_port()),
                     try!(n.get_o_selection()), try!(n.get_i_port()),
                     try!(n.get_i_selection()), try!(n.get_i_name()));
        }
        println!("\niips :");
        for n in try!(graph.borrow().get_iips()).iter() {
            println!("  '{}' -> {}[{}] {}()", try!(n.get_iip()), try!(n.get_comp()),
                     try!(n.get_port()), try!(n.get_selection()));
        }
        println!("\nexternal inputs :");
        for n in try!(graph.borrow().get_external_inputs()).iter() {
            println!("  {} => {}[{}] {}()", try!(n.get_name()), try!(n.get_port()),
                     try!(n.get_selection()), try!(n.get_comp()));
        }
        println!("\nexternal outputs :");
        for n in try!(graph.borrow().get_external_outputs()).iter() {
            println!("  {}() {}[{}] => {}", try!(n.get_comp()), try!(n.get_port()),
                     try!(n.get_selection()), try!(n.get_name()));
        }

        let _ = self.ports.send("output", ip);
        Ok(())
    }
}
