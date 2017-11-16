extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: bool),
    output(output: bool),
    fn run(&mut self) -> Result<Signal> {
        let a = self.input.input.recv()?;
        println!("boolean : {}", a);
        let _ = self.output.output.send(a);
        Ok(End)
    }
}
