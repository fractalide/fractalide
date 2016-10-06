#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    shells_lain_flow, contracts(list_command, file_desc)
    inputs(input: list_command),
    inputs_array(),
    outputs(output: file_desc),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let input_reader: list_command::Reader = ip_input.get_root()?;
        let cmds = input_reader.borrow().get_commands()?;
        let mut flow = String::from("");
        let mut switches: Vec<String> = Vec::new();
        let mut cmd_count :usize = 0;
        let cmd_len :usize = cmds.iter().len();
        for cmd in cmds.iter() {
            let mut formatted_args = String::from("");
            let mut command_contents: Vec<String> = Vec::new();
            let formatted_name = String::from(format!("name=\"{}\"",cmd.get_name()?));
            command_contents.push(formatted_name);
            let mut formatted_singles = String::from("singles=[");
            let singles_csv = cmd.get_singles()?
                .iter()
                .map(|o| {
                    match o {
                        Ok(x) => {let out = format!("\"{}\"", x); out},
                        Err(_) => String::new(),
                    }
                }).collect::<Vec<_>>().join(", ");
            formatted_singles.push_str(format!("{}]", singles_csv.as_str()).as_str());
            command_contents.push(formatted_singles);
            let mut formatted_kvs = String::from("kvs=[");
            let kvs_csv = cmd.get_kvs()?
                .iter()
                .map(|o| {
                    let first = match o.get_first() {
                        Ok(x) => x,
                        Err(_) => "",
                    };
                    let second = match o.get_second() {
                        Ok(x) => x,
                        Err(_) => "",
                    };
                    let out = format!("(first=\"{}\", second=\"{}\")", first, second);
                    out
                }).collect::<Vec<String>>().join(", ");
            formatted_kvs.push_str(format!("{}]", kvs_csv.as_str()).as_str());
            command_contents.push(formatted_kvs);
            formatted_args.push_str(
                format!("'command:({0})' -> option {1}_{2}()"
                    , command_contents.join(", ")
                    , cmd.get_name()?
                    , cmd_count).as_str());
            switches.push(formatted_args);
            if cmd_len == 1 { // only one command in the list
                flow.push_str(format!("{0}_{1}({0})", cmd.get_name()?, cmd_count).as_str());
                switches.push(format!("'generic_text:(text=\"/2/1/\")' -> stdin {0}_{1}()", cmd.get_name()?, cmd_count));
            } else { // more than one command
                if cmd_len > 1 && cmd_count == 0 { // the first command of many in a list
                    flow.push_str(format!("{0}_{1}({0}) stdout -> ", cmd.get_name()?, cmd_count).as_str());
                    switches.push(format!("'generic_text:(text=\"/2/1/\")' -> stdin {0}_{1}()", cmd.get_name()?, cmd_count));
                } else { // check if the last command or not
                    if (cmd_len - 1) == cmd_count { // last command
                        flow.push_str(format!("stdin {0}_{1}({0})", cmd.get_name()?, cmd_count).as_str());
                    } else { // not the first command, and not the last command
                        flow.push_str(format!("stdin {0}_{1}({0}) stdout -> ", cmd.get_name()?, cmd_count).as_str());
                    }
                }
            }
            cmd_count += 1;
        }
        println!("{:?}", flow);

        // Send start
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_start("flowscript");
        }
        self.ports.send("output", new_ip)?;

        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_text(&flow.as_str());
        }
        self.ports.send("output", new_ip)?;

        for switch in switches {
            println!("{:?}", switch);
            let mut new_ip = IP::new();
            {
                let mut ip = new_ip.init_root::<file_desc::Builder>();
                ip.set_text(&switch.as_str());
            }
            self.ports.send("output", new_ip)?;
        }

        // Send stop
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_end("flowscript");
        }
        self.ports.send("output", new_ip)?;
        Ok(())
    }
}
