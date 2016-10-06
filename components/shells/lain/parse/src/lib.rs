#![feature(question_mark)]

#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::collections::HashSet;

#[macro_use]
extern crate nom;

//mod parsers;
//use parsers::parse_lain_lang;

struct Command {
    name: String,
    singles: Vec<String>,
    kvs: Vec<(String, String)>,
}

component! {
    shells_lain_parse, contracts(generic_text, list_command)
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: list_command),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let raw_command = {
            let input_reader: generic_text::Reader = ip_input.get_root()?;
            input_reader.get_text()
        };
        //let parsed_commands = parse_lain_lang(raw_command?);
        let commands =
        vec![
            Command{
                name: String::from("shells_lain_commands_print"),
                singles: vec![String::from("hello")
                            , String::from("single")
                            , String::from("world 0")
                            ],
                kvs: vec![(String::from("key"), String::from("value"))
                        , (String::from("key"), String::from("value") )]
            },
            Command{
                name: String::from("shells_lain_commands_dirname"),
                singles: vec![String::from("-z")],
                kvs: vec![(String::from("key"), String::from("value"))
                        , (String::from("key"), String::from("value") )]
            },
            Command{
                name: String::from("shells_lain_commands_print"),
                singles: vec![String::from("hello")],
                kvs: vec![(String::from("key"), String::from("value"))
                        , (String::from("key"), String::from("value") )]
            },
            Command{
                name: String::from("shells_lain_commands_dirname"),
                singles: vec![String::from("--zero")],
                kvs: vec![(String::from("key"), String::from("value"))
                        , (String::from("key"), String::from("value") )]
            },
        ];
        let mut out_ip = IP::new();
        {
            let mut ip = out_ip.init_root::<list_command::Builder>();
            let mut cmd_count: u32 = 0;
            let mut list = ip.borrow().init_commands(commands.len() as u32);
            for command in commands {
                list.borrow().get(cmd_count).set_name(command.name.as_str());
                {
                    let mut slist = list.borrow().get(cmd_count).init_singles(command.singles.len() as u32);
                    let mut singles_count: u32 = 0;
                    for single in command.singles {
                        slist.borrow().set(singles_count, single.as_str());
                        singles_count += 1;
                    }
                }
                let mut kvlist = list.borrow().get(cmd_count).init_kvs(command.kvs.len() as u32);
                let mut kv_count: u32 = 0;
                for kv in command.kvs {
                    kvlist.borrow().get(kv_count).set_first(kv.0.as_str());
                    kvlist.borrow().get(kv_count).set_second(kv.1.as_str());
                    kv_count += 1;
                }
                cmd_count += 1;
            }
        }
        self.ports.send("output", out_ip)?;
        Ok(())
    }
}
