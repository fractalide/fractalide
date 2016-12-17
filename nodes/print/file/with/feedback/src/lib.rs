#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::str::FromStr;

agent! {
    input(input: list_triple),
    output(next: value_string),
    fn run(&mut self) -> Result<Signal> {
        loop{
            let mut msg = try!(self.input.input.recv());
            let list_triple: list_triple::Reader = try!(msg.read_schema());
            let list_triple = try!(list_triple.get_triples());
            if try!(list_triple.get(0).get_first()) == "end" {
                println!("{}",try!(list_triple.get(0).get_first()));
                break;
            } else {
                for i in 0..list_triple.len() {
                    let count = try!(list_triple.get(i).get_third());
                    if i32::from_str(count).unwrap() > 1 {
                        println!("{}",try!(list_triple.get(i).get_first()));
                        println!("{}",try!(list_triple.get(i).get_second()));
                        println!("{}",try!(list_triple.get(i).get_third()));
                    }
                }
            }
            let mut next_msg = Msg::new();
            {
                let mut msg = next_msg.build_schema::<value_string::Builder>();
                msg.set_value("next");
            }
            try!(self.output.next.send(next_msg));
        }
        Ok(End)
    }
}
