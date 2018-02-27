#[macro_use]
extern crate rustfbp;
extern crate capnp;
#[macro_use]
extern crate log;
use rustfbp::edges::core_graph::CoreGraph;
use rustfbp::edges::core_semantic_error::CoreSemanticError;
use rustfbp::edges::fs_file_error::FsFileError;

use std::fs;

agent! {
    input(file_error: FsFileError, semantic_error: CoreSemanticError),
    output(output: CoreGraph),
    fn run(&mut self) -> Result<Signal>{
        debug!("{:?}", env!("CARGO_PKG_NAME"));

        match self.input.semantic_error.try_recv() {
            Ok(error) => {
                println!("Graph at : {}", error.path);
                for error in error.parsing {
                    println!("  {}", error);
                }
                print!("");
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
