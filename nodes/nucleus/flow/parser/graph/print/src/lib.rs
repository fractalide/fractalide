#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: fbp_graph),
    output(output: fbp_graph),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = try!(self.input.input.recv());
        {
            let graph: fbp_graph::Reader = try!(msg.read_schema());

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
            println!("\nimsgs :");
            for n in try!(graph.borrow().get_imsgs()).iter() {
                println!("  '{}' -> {}[{}] {}()", try!(n.get_imsg()), try!(n.get_comp()),
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
        }

        let _ = self.output.output.send(msg);
        Ok(End)
    }
}
