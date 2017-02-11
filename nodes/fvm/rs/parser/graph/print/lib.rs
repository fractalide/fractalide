#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: core_graph),
    output(output: core_graph),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = try!(self.input.input.recv());
        {
            let graph: core_graph::Reader = try!(msg.read_schema());

            println!("Graph at : {}", graph.get_path()?);
            println!("nodes :");
            for n in graph.borrow().get_nodes()?.get_list()?.iter() {
                println!("  {}({})", n.get_name()?, n.get_sort()?);
            }
            println!("\nedges :");
            for n in graph.borrow().get_edges()?.get_list()?.iter() {
                println!("  {}() {}[{}] -> {}[{}] {}()", n.get_o_name()?, n.get_o_port()?,
                         n.get_o_selection()?, n.get_i_port()?,
                         n.get_i_selection()?, n.get_i_name()?);
            }
            println!("\nimsgs :");
            for n in graph.borrow().get_imsgs()?.get_list()?.iter() {
                println!("  '{}' -> {}[{}] {}()", n.get_imsg()?, n.get_comp()?,
                         n.get_port()?, n.get_selection()?);
            }
            println!("\nexternal inputs :");
            for n in graph.borrow().get_external_inputs()?.get_list()?.iter() {
                println!("  {} => {}[{}] {}()", n.get_name()?, n.get_port()?,
                         n.get_selection()?, n.get_comp()?);
            }
            println!("\nexternal outputs :");
            for n in graph.borrow().get_external_outputs()?.get_list()?.iter() {
                println!("  {}() {}[{}] => {}", n.get_comp()?, n.get_port()?,
                         n.get_selection()?, n.get_name()?);
            }
        }

        let _ = self.output.output.send(msg);
        Ok(End)
    }
}
