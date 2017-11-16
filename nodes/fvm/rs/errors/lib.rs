#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;

agent! {
    input(file_error: FsFileError, semantic_error: CoreSemanticError),
    output(output: CoreGraph),
    fn run(&mut self) -> Result<Signal>{

        match self.input.semantic_error.try_recv() {
            Ok(error) => {
                println!("Graph at : {}", error.path);
                for error in error.parsing {
                    println!("  {}", error);
                }
                println!("");
            }
            _ => {}
        };

        match self.input.file_error.try_recv() {
            Ok(error) => {
                println!("Subgraph doesn't exist at file location : {}\n", error.0);
            }
            _ => {}
        };


        // TODO : remove allocation by building a new CoreGraph constructor
        let mut g = CoreGraph::new();
        g.path = "error".into();
        let _ = self.output.output.send(g);
        Ok(End)
    }
}
