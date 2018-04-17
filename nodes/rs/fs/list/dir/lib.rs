#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

use std::fs;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    input(input: fs_path),
    output(output: fs_list_path),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));

        let mut msg = try!(self.input.input.recv());
        let path: fs_path::Reader = msg.read_schema()?;
        let mut new_msg = Msg::new();
        {
            let msg = new_msg.build_schema::<fs_list_path::Builder>();
            let mut listOfFiles = msg.init_list(fs::read_dir(path.get_path()?)?.count() as u32);
            let mut i: u32 = 0;
            for path in fs::read_dir(path.get_path()?)? {
                listOfFiles.borrow().get(i).set_path(path?.path().to_str().unwrap());
                i += 1;
            }
        }
        self.output.output.send(new_msg)?;
        Ok(End)
    }
}
