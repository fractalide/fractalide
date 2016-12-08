#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    fs_file_open, edges(path, file_desc, file_error)
    inputs(input: path),
    inputs_array(),
    outputs(output: file_desc, error: file_error),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get the path
        let mut ip = try!(self.ports.recv("input"));
        let path: path::Reader = try!(ip.read_schema());

        let path = try!(path.get_path());

        let file = match File::open(path) {
            Ok(file) => { file },
            Err(_) => {
                // Prepare the output ip
                let mut new_ip = IP::new();

                {
                    let mut ip = new_ip.build_schema::<file_error::Builder>();
                    ip.set_not_found(&path);
                }
                let _ = self.ports.send("error", new_ip);
                return Ok(());
            }
        };


        // Send start
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.build_schema::<file_desc::Builder>();
            ip.set_start(&path);
        }
        try!(self.ports.send("output", new_ip));

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            let l = try!(line);
            let mut new_ip = IP::new();
            {
                let mut ip = new_ip.build_schema::<file_desc::Builder>();
                ip.set_text(&l);
            }
            try!(self.ports.send("output", new_ip));
        }

        // Send stop
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.build_schema::<file_desc::Builder>();
            ip.set_end(&path);
        }
        try!(self.ports.send("output", new_ip));

        Ok(())

    }

}
