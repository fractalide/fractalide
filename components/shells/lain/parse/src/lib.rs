#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::collections::HashSet;

#[macro_use]
extern crate nom;

mod parsers;
use parsers::parse_lain_lang;

component! {
    shells_lain_parse, contracts(generic_text, list_list_list_text)
    inputs(input: generic_text),
    inputs_array(),
    outputs(output: list_list_list_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let raw_command = {
            let input_reader: generic_text::Reader = ip_input.get_root()?;
            input_reader.get_text()
        };
        let parsed_commands = parse_lain_lang(raw_command?);
        let mock_commands =
            vec![ // file
                vec![ // line
                    vec![ // pipes
                        vec![ "ls1", "-l", "-a" ], // command + args
                        vec![ "ls1", "-l", "-a" ],
                    ],
                    vec![
                        vec![ "ls1", "-l", "-a" ],
                        vec![ "ls1", "-l", "-a" ],
                    ],
                ],
                vec![
                    vec![
                        vec![ "ls1", "-l", "-a" ],
                        vec![ "ls1", "-l", "-a" ],
                    ],
                    vec![
                        vec![ "ls1", "-l", "-a" ],
                        vec![ "ls1", "-l", "-a" ],
                    ],
                ],
            ];
        //println!("{:?}", parsed_commands );
        let mut out_ip = IP::new();
        {
            let mut ip = out_ip.init_root::<list_list_list_text::Builder>();
            for file in mock_commands {
                let mut line_count: u32 = 0;
                let mut list_0 = ip.borrow().init_list(file.len() as u32);
                for line in file {
                    let mut pipe_count: u32 = 0;
                    let mut list_1 = list_0.borrow().get(line_count).init_list(line.len() as u32);
                    for pipes in line {
                        let mut argument_count: u32 = 0;
                        let mut list_of_texts = list_1.borrow().get(pipe_count).init_texts(pipes.len() as u32);
                        for argument in pipes {
                            list_of_texts.borrow().set(argument_count, argument);
                            argument_count += 1;
                        }
                        pipe_count += 1;
                    }
                    line_count += 1;
                }
            }
        }
        self.ports.send("output", out_ip)?;
        Ok(())
    }
}
