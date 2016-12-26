#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::process::Command;
use std::process;
use std::path::Path;
use std::env;

agent! {
    input(path: fs_path, edge: prim_text, input: prim_text),
    output(output: any),
    fn run(&mut self) -> Result<Signal>{

        let mut path_msg = self.input.path.recv()?;
        let path: fs_path::Reader = path_msg.read_schema()?;
        let path = path.get_path()?.get_text()?;

        let mut edge_msg = self.input.edge.recv()?;
        let edge: prim_text::Reader = edge_msg.read_schema()?;
        let f_edge = edge.get_text()?;

        let mut input_msg = self.input.input.recv()?;
        let input: prim_text::Reader = input_msg.read_schema()?;
        let input = input.get_text()?;

        let mut child = Command::new("capnp_path" )
            .arg("encode")
            .arg(path)
            .arg(f_edge)
            .stdin(process::Stdio::piped())
            .stdout(process::Stdio::piped())
            .spawn()
            ?;

        if let Some(ref mut stdin) = child.stdin {
            stdin.write_all(input.as_bytes())?;
        } else {
            unreachable!();
        }
        let output = child.wait_with_output()?;

        if !output.status.success() {
            return Err(result::Error::Misc("capnp encode command doesn't work".into()));
        }

        let mut send_msg = Msg::new();
        send_msg.vec = output.stdout;
        let _ = self.output.output.send(send_msg);
        Ok(End)
    }
}
