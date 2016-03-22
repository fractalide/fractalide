extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("file_list.rs");
    include!("path.rs");
}

use self::contracts::file_list;
use self::contracts::path;

use std::fs;
use std::io::BufReader;
use std::io::BufRead;

component! {
    FsDirList,
    inputs(input: path),
    inputs_array(),
    outputs(output: file_list),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let mut ip = try!(self.ports.recv("input"));
        let path = try!(ip.get_reader());
        let path: path::Reader = try!(path.get_root());
        let paths = try!(fs::read_dir(try!(path.get_path())));

        let mut new_ip = capnp::message::Builder::new_default();
        {
            let ip = new_ip.init_root::<file_list::Builder>();
            let mut files = ip.init_files(try!(fs::read_dir(try!(path.get_path()))).count() as u32);
            let mut i: u32 = 0;
            for path in try!(fs::read_dir(try!(path.get_path()))) {
                files.borrow().set(i, try!(path).path().to_str().unwrap());
                i += 1;
            }
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&new_ip));
        try!(self.ports.send("output", send_ip));
        Ok(())
    }
}
