#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::process::Command;
use std::process;
use std::path::Path;
use std::env;

agent! {
    input(path: path, edge: prim_text, input: prim_text),
    output(output: any),
    fn run(&mut self) -> Result<Signal>{

        let mut path_msg = try!(self.input.path.recv());
        let path: path::Reader = try!(path_msg.read_schema());
        let path = try!(path.get_path());

        let mut edge_msg = try!(self.input.edge.recv());
        let edge: prim_text::Reader = try!(edge_msg.read_schema());
        let f_edge = try!(edge.get_text());

        let mut input_msg = try!(self.input.input.recv());
        let input: prim_text::Reader = try!(input_msg.read_schema());
        let input = try!(input.get_text());

        let mut child = try!(Command::new("capnp_path" )
            .arg("encode")
            .arg(path)
            .arg(f_edge)
            .stdin(process::Stdio::piped())
            .stdout(process::Stdio::piped())
            .spawn()
            );

        if let Some(ref mut stdin) = child.stdin {
            try!(stdin.write_all(input.as_bytes()));
        } else {
            unreachable!();
        }
        let output = try!(child.wait_with_output());

        if !output.status.success() {
            return Err(result::Error::Misc("capnp encode command doesn't work".into()));
        }

        let mut send_msg = Msg::new();
        send_msg.vec = output.stdout;
        let _ = self.output.output.send(send_msg);
        Ok(End)
    }
}
