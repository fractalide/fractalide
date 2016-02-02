extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("file.rs");
}

use self::contracts::file;

component! {
    file_open,
    inputs(input: path),
    inputs_array(),
    outputs(output: file),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get one IP
        let mut ip = try!(self.ports.recv("input"));
        let file = try!(ip.get_reader());
        let file: file::Reader = try!(file.get_root());
        // Send outside (don't care about loss)
        let _ = self.ports.send("output", ip);
        // print it
        match try!(file.which()) {
            file::Start(path) => {
                println!("Start : {} ", try!(path));
                loop {
                    // Get one IP
                    let mut ip = try!(self.ports.recv("input"));
                    let file = try!(ip.get_reader());
                    let file: file::Reader = try!(file.get_root());
                    // Send outside (don't care about loss)
                    let _ = self.ports.send("output", ip);

                    match try!(file.which()) {
                      file::Text(text) => { println!("Text : {} ", try!(text)); },
                      file::End(path) => { println!("End : {} ", try!(path)); break; },
                      _ => { return Err(result::Error::Misc("bad stream".to_string())); },
                    }
                }
            },
            _ => { return Err(result::Error::Misc("bad stream".to_string())); },
        }
        Ok(())
    }
}
