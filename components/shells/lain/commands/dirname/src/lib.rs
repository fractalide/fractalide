#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::path::Path;

component! {
    shells_lain_commands_dirname, contracts(generic_text, command)
    inputs(stdin: generic_text),
    inputs_array(),
    outputs(stdout: generic_text),
    outputs_array(),
    option(command),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut opt = self.recv_option();
        let mut stdin_ip = self.ports.recv("stdin")?;
        let mut out = String::new();
        let mut separator = String::new();
        {
            let reader: command::Reader = opt.read_contract()?;
            let singles = reader.get_singles()?
                .iter()
                .map(|o| {
                    match o {
                        Ok(x) => x,
                        Err(_) => "",
                    }
                }).collect::<Vec<_>>();
            let sep = if singles.contains(&"--zero") || singles.contains(&"-z") {"\0"} else {"\n"};
            separator.push_str(sep);
            {
                let stdin_reader: generic_text::Reader = stdin_ip.read_contract()?;
                let path = stdin_reader.get_text();

                let p = Path::new(path?);
                match p.parent() {
                    Some(d) => {
                        if d.components().next() == None {
                            out.push_str(".");
                        } else {
                            match d.to_str() {
                                Some(e) => out.push_str(e),
                                None => {},
                            }
                        }
                    }
                    None => {
                        if p.is_absolute() || path? == "/" {
                            out.push_str("/");
                        } else {
                            out.push_str(".");
                        }
                    }
                }
            }
            let mut new_ip = IP::new();
            {
                let mut ip = new_ip.build_contract::<generic_text::Builder>();
                out.push_str(separator.as_str());
                ip.set_text(out.as_str());
            }
            self.ports.send("stdout", new_ip);
        }
        Ok(())
    }
}
