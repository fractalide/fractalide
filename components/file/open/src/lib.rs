extern crate capnp;

#[macro_use]
extern crate rustfbp;
use rustfbp::component::*;

component! {
    file_open,
    inputs(input: path),
    inputs_array(),
    outputs(output: file),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) {

        // Get the path
        let mut ip = self.ports.recv("input".into()).expect("file_open : unable to receive from input");
        let path = ip.get_reader().expect("file_open: cannot get the reader");
        let path: path::Reader = path.get_root().expect("file_open: not a file_name reader");

        let path = path.get_path().expect("file_open: cannot get the name");

        // Send start
        let mut new_ip = super::capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<file::Builder>();
            ip.set_start(&path);
        }
        let mut send_ip = self.allocator.ip.build_empty();
        send_ip.write_builder(&new_ip).expect("file_open: cannot write");
        self.ports.send("output".into(), send_ip).expect("file_open: cannot send start");

        // Send lines
        let file = File::open(path).expect("file_open: cannot open file");
        let file = BufReader::new(&file);
        for line in file.lines() {
            let l = line.expect("cannot get a line");
            let mut new_ip = super::capnp::message::Builder::new_default();
            {
                let mut ip = new_ip.init_root::<file::Builder>();
                ip.set_text(&l);
            }
            let mut send_ip = self.allocator.ip.build_empty();
            send_ip.write_builder(&new_ip).expect("file_open: cannot write");
            self.ports.send("output".into(), send_ip).expect("file_open: cannot send line");
        }

        // Send stop
        let mut new_ip = super::capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<file::Builder>();
            ip.set_end(&path);
        }
        let mut send_ip = self.allocator.ip.build_empty();
        send_ip.write_builder(&new_ip).expect("file_open: cannot write");
        self.ports.send("output".into(), send_ip).expect("file_open: cannot send start");


    }

    mod contracts {
        include!("path_capnp.rs");
        include!("file_capnp.rs");
    }

    use self::contracts::file;
    use self::contracts::path;

    use std::fs::File;
    use std::io::BufReader;
    use std::io::BufRead;
}
