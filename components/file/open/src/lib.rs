extern crate capnp;

#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

mod contracts {
    include!("path.rs");
    include!("file.rs");
    include!("file_error.rs");
}

use self::contracts::file;
use self::contracts::file_error;
use self::contracts::path;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

component! {
    file_open,
    inputs(input: path),
    inputs_array(),
    outputs(output: file, error: file_error),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {

        // Get the path
        let mut ip = self.ports.recv("input".into()).expect("file_open : unable to receive from input");
        let path = ip.get_reader().expect("file_open: cannot get the reader");
        let path: path::Reader = path.get_root().expect("file_open: not a file_name reader");

        let path = path.get_path().expect("file_open : cannot read path");

        let file = match File::open(path) {
            Ok(file) => { file },
            Err(_) => {
                // Prepare the output ip
                let mut new_ip = capnp::message::Builder::new_default();
                let mut send_ip = self.allocator.ip.build_empty();

                {
                    let mut ip = new_ip.init_root::<file_error::Builder>();
                    ip.set_not_found(&path);
                }
                send_ip.write_builder(&new_ip).expect("file_open: cannot write");
                let _ = self.ports.send("error".into(), send_ip);
                return;
            }
        };


        // Send start
        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<file::Builder>();
            ip.set_start(&path);
        }
        let mut send_ip = self.allocator.ip.build_empty();
        send_ip.write_builder(&new_ip).expect("file_open: cannot write");
        self.ports.send("output".into(), send_ip).expect("file_open: cannot send start");

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            let l = line.expect("cannot get a line");
            let mut new_ip = capnp::message::Builder::new_default();
            {
                let mut ip = new_ip.init_root::<file::Builder>();
                ip.set_text(&l);
            }
            let mut send_ip = self.allocator.ip.build_empty();
            send_ip.write_builder(&new_ip).expect("file_open: cannot write");
            self.ports.send("output".into(), send_ip).expect("file_open: cannot send line");
        }

        // Send stop
        let mut new_ip = capnp::message::Builder::new_default();
        let mut send_ip = self.allocator.ip.build_empty();
        {
            let mut ip = new_ip.init_root::<file::Builder>();
            ip.set_end(&path);
        }
        send_ip.write_builder(&new_ip).expect("file_open: cannot write");
        self.ports.send("output".into(), send_ip).expect("file_open: cannot send start");


    }

}
