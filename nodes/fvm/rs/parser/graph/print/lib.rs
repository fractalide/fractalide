#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

use rustfbp::edges::core_graph::CoreGraph;

agent! {
    input(input: CoreGraph),
    output(output: CoreGraph),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        let graph = self.input.input.recv()?;
        println!("{:?}", graph);
        let _ = self.output.output.send(graph);
        Ok(End)
    }
}
