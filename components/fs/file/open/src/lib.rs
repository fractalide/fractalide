extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("path.rs");
    include!("file_desc.rs");
    include!("file_error.rs");
}

use contracts::file_error;
use contracts::file_desc;
use contracts::path;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

component! {
    FileOpen,
    inputs(input: path),
    inputs_array(),
    outputs(output: file_desc, error: file_error),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("input"));
        let path = try!(ip.get_reader());
        let path: path::Reader = try!(path.get_root());

        let path = try!(path.get_path());

        let file = match File::open(path) {
            Ok(file) => { file },
            Err(_) => {
                // Prepare the output ip
                let mut new_ip = capnp::message::Builder::new_default();
                let mut send_ip = IP::new();

                {
                    let mut ip = new_ip.init_root::<file_error::Builder>();
                    ip.set_not_found(&path);
                }
                try!(send_ip.write_builder(&new_ip));
                let _ = self.ports.send("error", send_ip);
                return Ok(());
            }
        };


        // Send start
        let mut new_ip = capnp::message::Builder::new_default();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_start(&path);
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&new_ip));
        try!(self.ports.send("output", send_ip));

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            let l = try!(line);
            let mut new_ip = capnp::message::Builder::new_default();
            {
                let mut ip = new_ip.init_root::<file_desc::Builder>();
                ip.set_text(&l);
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&new_ip));
            try!(self.ports.send("output", send_ip));
        }

        // Send stop
        let mut new_ip = capnp::message::Builder::new_default();
        let mut send_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_end(&path);
        }
        try!(send_ip.write_builder(&new_ip));
        try!(self.ports.send("output", send_ip));

        Ok(())

    }

}
