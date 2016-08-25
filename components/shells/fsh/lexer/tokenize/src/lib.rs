#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::collections::HashSet;

component! {
    shells_fsh_build_names, contracts(list_text, shell_commands)
    inputs(input: list_text),
    inputs_array(),
    outputs(output: list_text),
    outputs_array(),
    option(shell_commands),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_option = self.recv_option();
        let mut commands_reader: shell_commands::Reader = ip_option.get_root()?;
        let mut command_lookup = HashMap::new();
        for cmd in commands_reader.get_commands()?.iter() {
            command_lookup.insert(cmd.get_key()?.clone(), cmd.get_val()?.clone());
        }
        loop {
            let mut ip_input = self.ports.recv("input")?;
            let input = {
                let input_reader: list_text::Reader = ip_input.get_root()?;
                input_reader.get_texts()
            };
            let mut unknown_commands: HashSet<&str> = HashSet::new();
            let mut out_ip_output = IP::new();
            {
                let ip = out_ip_output.init_root::<list_text::Builder>();
                let mut commands = ip.init_texts(input?.len() as u32);
                let mut i: u32 = 0;
                for cmd in input?.iter() {
                    match command_lookup.get(cmd?) {
                        Some(command_location) => {commands.borrow().set(i, command_location);},
                        None => {unknown_commands.insert(cmd?);},
                    }
                    i += 1;
                }
            }
            if unknown_commands.is_empty() {self.ports.send("output", out_ip_output)?;}
            else {
                for cmd in unknown_commands {
                    println!("{} not found.", cmd);
                }
            }
        }
        Ok(())
    }
}
