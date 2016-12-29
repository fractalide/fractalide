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

            println!("Graph at : {}", graph.get_path()?.get_text()?);
            println!("nodes :");
            for n in graph.borrow().get_nodes()?.get_list()?.iter() {
                println!("  {}({})", n.get_name()?.get_text()?, n.get_sort()?.get_text()?);
            }
            println!("\nedges :");
            for n in graph.borrow().get_edges()?.get_list()?.iter() {
                println!("  {}() {}[{}] -> {}[{}] {}()", n.get_o_name()?.get_text()?, n.get_o_port()?.get_text()?,
                         n.get_o_selection()?.get_text()?, n.get_i_port()?.get_text()?,
                         n.get_i_selection()?.get_text()?, n.get_i_name()?.get_text()?);
            }
            println!("\nimsgs :");
            for n in graph.borrow().get_imsgs()?.get_list()?.iter() {
                println!("  '{}' -> {}[{}] {}()", n.get_imsg()?.get_text()?, n.get_comp()?.get_text()?,
                         n.get_port()?.get_text()?, n.get_selection()?.get_text()?);
            }
            println!("\nexternal inputs :");
            for n in graph.borrow().get_external_inputs()?.get_list()?.iter() {
                println!("  {} => {}[{}] {}()", n.get_name()?.get_text()?, n.get_port()?.get_text()?,
                         n.get_selection()?.get_text()?, n.get_comp()?.get_text()?);
            }
            println!("\nexternal outputs :");
            for n in graph.borrow().get_external_outputs()?.get_list()?.iter() {
                println!("  {}() {}[{}] => {}", n.get_comp()?.get_text()?, n.get_port()?.get_text()?,
                         n.get_selection()?.get_text()?, n.get_name()?.get_text()?);
            }
        }

        let _ = self.output.output.send(msg);
        Ok(End)
    }
}
