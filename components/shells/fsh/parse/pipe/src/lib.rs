#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::str;

component! {
    shells_fsh_parse_pipe, contracts(generic_text)
    inputs(parse: generic_text),
    inputs_array(),
    outputs(output: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_parse = self.ports.recv("parse")?;
        let raw_command = {
            let parse_reader: generic_text::Reader = ip_parse.get_root()?;
            parse_reader.get_text()
        };
        let command = String::from(raw_command?);
        let mut pipe_commands: Vec<&str>;
        if command.contains('|') {
            pipe_commands = command.split('|').collect();
        } else {
            pipe_commands = Vec::new();
            pipe_commands.push(command.as_str());
        }
        for pipe_section in pipe_commands {
            let mut send_ip = IP::new();
            {
                let mut ip = send_ip.init_root::<generic_text::Builder>();
                ip.set_text(pipe_section);
            }
            self.ports.send("output", send_ip)?;
        }
        Ok(())
    }
}
