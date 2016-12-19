#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::path::Path;

agent! {
    input(stdin: generic_text),
    output(stdout: generic_text),
    option(command),
    fn run(&mut self) -> Result<Signal> {
        let mut opt = self.recv_option();
        let mut stdin_ip = self.input.stdin.recv()?;
        let mut out = String::new();
        let mut separator = String::new();
        {
            let reader: command::Reader = opt.read_schema()?;
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
                let stdin_reader: generic_text::Reader = stdin_ip.read_schema()?;
                let path = stdin_reader.get_text();

                let p = Path::new(path?);
                match p.parent() {
                    Some(d) => {
                        if d.agents().next() == None {
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
                let mut ip = new_ip.build_schema::<generic_text::Builder>();
                out.push_str(separator.as_str());
                ip.set_text(out.as_str());
            }
            self.output.stdout.send(new_ip);
        }
        Ok(End)
    }
}
