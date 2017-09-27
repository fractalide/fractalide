extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    rsinput(input: bool),
    rsoutput(output: bool),
    fn run(&mut self) -> Result<Signal> {
        let a = self.rsinput.input.recv()?;
        println!("boolean : {}", a);
        self.rsoutput.output.send(a)?;
        Ok(End)
    }
}
