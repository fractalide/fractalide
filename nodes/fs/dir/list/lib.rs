#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    input(input: path),
    output(output: file_list),
    fn run(&mut self) -> Result<Signal> {

        let mut msg = try!(self.input.input.recv());
        let path: path::Reader = try!(msg.read_schema());
        let mut new_msg = Msg::new();
        {
            let msg = new_msg.build_schema::<file_list::Builder>();
            let mut files = msg.init_files(try!(fs::read_dir(try!(path.get_path()))).count() as u32);
            let mut i: u32 = 0;
            for path in try!(fs::read_dir(try!(path.get_path()))) {
                files.borrow().set(i, try!(path).path().to_str().unwrap());
                i += 1;
            }
        }
        try!(self.output.output.send(new_msg));
        Ok(End)
    }
}
