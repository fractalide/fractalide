#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: CoreGraph),
    output(output: CoreGraph),
    fn run(&mut self) -> Result<Signal> {
        let graph = self.input.input.recv()?;
        println!("{:?}", graph);
        let _ = self.output.output.send(graph);
        Ok(End)
    }
}
