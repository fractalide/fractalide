#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

use rustfbp::edges::fs_path::FsPath;
use rustfbp::edges::fs_file_desc::FsFileDesc;
use rustfbp::edges::fs_file_error::FsFileError;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    input(input: FsPath),
    output(output: FsFileDesc, error: FsFileError),
    fn run(&mut self) -> Result<Signal> {
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        // Get the path
        let mut path = self.input.input.recv()?;

        let file = match File::open(&path.0) {
            Ok(file) => { file },
            Err(_) => {
                let _ = self.output.error.send(FsFileError(path.0.clone()));
                return Ok(End);
            }
        };


        // Send start
        self.output.output.send(FsFileDesc::Start(path.0.clone()))?;

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            self.output.output.send(FsFileDesc::Text(line?))?;
        }

        // Send stop
        self.output.output.send(FsFileDesc::End(path.0))?;
        Ok(End)

    }

}
