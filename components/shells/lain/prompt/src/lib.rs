#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate toml;
extern crate libc;
extern crate copperline;

use std::thread;
use std::env::{current_dir, home_dir};
use std::io::stdout;
use copperline::Copperline;

pub struct Prompt {
    user_prompt: String,
    cwd: String,
}

impl Prompt {
    pub fn new() -> Prompt {
        let mut object = Prompt {
            user_prompt: "lain > ".to_owned(),
            cwd: "~/".to_owned(),
        };
        object.update_cwd();
        object
    }

    pub fn get_user_prompt(&self) -> String {
        self.user_prompt.to_owned()
    }

    pub fn get_cwd(&self) -> String {
        self.cwd.to_owned()
    }

    pub fn update_cwd(&mut self){
        let buff = current_dir().ok().expect("No current directory");

        if buff.starts_with(home_dir().expect("No Home directory").as_path()){
        let mut home = "~/".to_owned();
            home.push_str(buff.as_path()
                .to_str().expect("Failed to become a str"));
            self.cwd = home;
        } else {
            self.cwd = buff.as_path()
                .to_str().expect("Failed to turn path into str").to_owned();
        }

    }

    pub fn print(&self) {
        print!("{}", self.get_user_prompt());
        stdout().flush().ok().expect("Could not flush stdout");
    }

}

component! {
  shells_lain_prompt, contracts(generic_text)
  inputs(),
  inputs_array(),
  outputs(output: generic_text),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut prompt = Prompt::new();
    let mut input_buffer = Copperline::new();
    println!("Copyright - Noware Ltd. Hong Kong");
    println!("License - Mozilla Public License v2");
    println!("Welcome to the Fractalide Shell.");
    println!("Type 'exit' then <ctl>-c to quit.");

    loop {
        let line = input_buffer.read_line_utf8(&prompt.get_user_prompt()).ok();
        if line.is_none(){
            continue;
        }
        let command = line.expect("Could not get line");
        input_buffer.add_history(command.clone());
        if command.is_empty() {
            prompt.print();
            continue;
        } else if command.starts_with("exit") {
            println!("bye");
            break;
        }
        let mut out_ip_output = IP::new();
        {
          let mut variable = out_ip_output.init_root::<generic_text::Builder>();
          variable.set_text(command.as_str());
        }
        self.ports.send("output", out_ip_output)?;
        prompt.print();
    }
    Ok(())
  }
}
