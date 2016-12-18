#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;

agent! {
    input(file_error: file_error, semantic_error: fbp_semantic_error),
    output(output: fbp_graph),
    fn run(&mut self) -> Result<Signal>{

        match self.input.semantic_error.try_recv() {
            Ok(mut msg) => {
                let error: fbp_semantic_error::Reader = try!(msg.read_schema());

                println!("Graph at : {}", try!(error.get_path()));
                let parsing = try!(error.get_parsing());
                for i in 0..parsing.len() {
                    println!("  {}", try!(parsing.get(i)));
                }
                println!("");
            }
            _ => {}
        };

        match self.input.file_error.try_recv() {
            Ok(mut msg) => {
                let error: file_error::Reader = try!(msg.read_schema());
                println!("Subgraph doesn't exist at file location : {}\n", try!(error.get_not_found()));
            }
            _ => {}
        };


        let mut new_msg = Msg::new();
        {
            let mut msg = new_msg.build_schema::<fbp_graph::Builder>();
            msg.set_path("error");
        }
        let _ = self.output.output.send(new_msg);
        Ok(End)
    }
}
