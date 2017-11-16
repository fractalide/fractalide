#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(add: String, halt: bool),
    output(output: CoreAction),
    fn run(&mut self) -> Result<Signal>{
        if let Ok(path) = self.input.add.try_recv() {
            self.output.output.send(CoreAction::Add(CoreActionAdd{
                name: "main".into(),
                comp: path,
            }))?;
        }
        if let Ok(_) = self.input.halt.try_recv() {
            self.output.output.send(CoreAction::Halt)?;
        }
        Ok(End)
    }
}
