#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::str;

component! {
    shells_lain_pipe, contracts(generic_text, list_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: list_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let raw_command = {
            let input_reader: generic_text::Reader = ip_input.get_root()?;
            input_reader.get_text()
        };
        let command = String::from(raw_command?);
        let mut pipe_commands: Vec<&str>;
        if command.contains('|') {
            pipe_commands = command.split('|').collect();
        } else {
            pipe_commands = Vec::new();
            pipe_commands.push(command.as_str());
        }
        let mut out_ip_output = IP::new();
        {
            let ip = out_ip_output.init_root::<list_text::Builder>();
            let mut commands = ip.init_texts(pipe_commands.len() as u32);
            let mut i: u32 = 0;
            for cmd in pipe_commands {
                commands.borrow().set(i, cmd);
                i += 1;
            }
        }
        self.ports.send("output", out_ip_output)?;
        Ok(())
    }
}
