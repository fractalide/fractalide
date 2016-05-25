#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::process::Command;
use std::process;
use std::path::Path;
use std::env;

component! {
    fvm, contracts(path, generic_text)
    inputs(path: path, contract: generic_text, input: generic_text),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()>{

        let mut path_ip = try!(self.ports.recv("path"));
        let path: path::Reader = try!(path_ip.get_root());
        let path = try!(path.get_path());

        let mut contract_ip = try!(self.ports.recv("contract"));
        let contract: generic_text::Reader = try!(contract_ip.get_root());
        let f_contract = try!(contract.get_text());

        let mut input_ip = try!(self.ports.recv("input"));
        let input: generic_text::Reader = try!(input_ip.get_root());
        let input = try!(input.get_text());

        let mut child = try!(Command::new("capnp_path" )
            .arg("encode")
            .arg(path)
            .arg(f_contract)
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

        let mut send_ip = IP::new();
        send_ip.vec = output.stdout;
        let _ = self.ports.send("output", send_ip);
        Ok(())
    }
}
