#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    input(input: fs_path),
    output(output: fs_file_desc, error: fs_file_error),
    fn run(&mut self) -> Result<Signal> {
        // Get the path
        let mut msg = try!(self.input.input.recv());
        let path: fs_path::Reader = msg.read_schema()?;

        let path = path.get_path()?.get_text()?;

        let file = match File::open(path) {
            Ok(file) => { file },
            Err(_) => {
                // Prepare the output msg
                let mut new_msg = Msg::new();

                {
                    let mut msg = new_msg.build_schema::<fs_file_error::Builder>();
                    msg.get_not_found()?.set_text(&path);
                }
                let _ = self.output.error.send(new_msg);
                return Ok(End);
            }
        };


        // Send start
        let mut new_msg = Msg::new();
        {
            let mut msg = new_msg.build_schema::<fs_file_desc::Builder>();
            msg.init_start().set_text(&path);
        }
        try!(self.output.output.send(new_msg));

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            let l = try!(line);
            let mut new_msg = Msg::new();
            {
                let msg = new_msg.build_schema::<fs_file_desc::Builder>();
                msg.init_text().set_text(&l);
            }
            try!(self.output.output.send(new_msg));
        }

        // Send stop
        let mut new_msg = Msg::new();
        {
            let mut msg = new_msg.build_schema::<fs_file_desc::Builder>();
            msg.init_end().set_text(&path);
        }
        try!(self.output.output.send(new_msg));

        Ok(End)

    }

}
