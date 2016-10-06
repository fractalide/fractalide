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
        let mut cmds = input_reader.borrow().get_commands()?;
        let mut flow = String::from("");
        let mut args: Vec<String> = Vec::new();
        let mut cmd_count :usize = 0;
        let cmd_len :usize = cmds.iter().len();
        for cmd in cmds.iter() {
            let mut formatted_args = String::from("");
            let mut formatted_singles = String::from("singles=[");
            let singles_csv = cmd.get_singles()?
                .iter()
                .map(|O| {
                    match O {
                        Ok(x) => {let out = format!("\"{}\"", x); out},
                        Err(e) => String::from(""),
                    }
                }).collect::<Vec<_>>().join(",");
            formatted_singles.push_str(format!("{}]", singles_csv.as_str()).as_str());
            formatted_args.push_str(
                format!("'command:({0})' -> option {1}_{2}()"
                    , formatted_singles
                    , cmd.get_name()?
                    , cmd_count).as_str());
            args.push(formatted_args);
            if cmd_len == 1 { // only one command in the list
                flow.push_str(format!("{0}_{1}({0})", cmd.get_name()?, cmd_count).as_str());
                args.push(format!("'generic_text:(text=\"/2/1/\")' -> stdin {0}_{1}()", cmd.get_name()?, cmd_count));
            } else { // more than one command
                if cmd_len > 1 && cmd_count == 0 { // the first command of many in a list
                    flow.push_str(format!("{0}_{1}({0}) stdout -> ", cmd.get_name()?, cmd_count).as_str());
                    args.push(format!("'generic_text:(text=\"start\")' -> stdin {0}_{1}()", cmd.get_name()?, cmd_count));
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

        for arg in args {
            println!("{:?}", arg);
            let mut new_ip = IP::new();
            {
                let mut ip = new_ip.init_root::<file_desc::Builder>();
                ip.set_text(&arg.as_str());
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
