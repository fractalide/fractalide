#[macro_use]
extern crate rustfbp;
extern crate capnp;

use std::fs::File;
use std::io::BufReader;
use std::io::BufRead;

agent! {
    input(input: String),
    output(output: FsFileDesc, error: String),
    fn run(&mut self) -> Result<Signal> {
        // Get the path
        let mut path = self.input.input.recv()?;

        let file = match File::open(&path) {
            Ok(file) => { file },
            Err(_) => {
                let _ = self.output.error.send(path);
                return Ok(End);
            }
        };


        // Send start
        self.output.output.send(FsFileDesc::Start(path.clone()))?;

        // Send lines
        let file = BufReader::new(&file);
        for line in file.lines() {
            self.output.output.send(FsFileDesc::Text(line?))?;
        }

        // Send stop
        self.output.output.send(FsFileDesc::End(path))?;
        Ok(End)

    }

}
