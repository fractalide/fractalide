extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
    include!("file_desc.rs");
}

use self::contracts::file_desc;

component! {
    fs_file_print,
    inputs(input: path),
    inputs_array(),
    outputs(output: file_desc),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        // Get one IP
        let mut ip = try!(self.ports.recv("input"));
        {
            let file: file::Reader = try!(ip.get_root());
            // print it
            match try!(file.which()) {
                file::Start(path) => { println!("Start : {}", try(path)); },
                file::Text(text) => { println!("Text : {} ", try!(text)); },
                file::End(path) => { println!("End : {} ", try!(path)); },
            }
        }
        // Send outside (don't care about loss)
        let _ = self.ports.send("output", ip);
        Ok(())
    }
}

