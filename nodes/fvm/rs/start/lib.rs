#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;
use rustfbp::edges::core_action::{CoreAction, CoreActionAdd};
use rustfbp::edges::fs_path::FsPath;

agent! {
    input(add: FsPath, halt: bool),
    output(output: CoreAction),
    fn run(&mut self) -> Result<Signal>{
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        if let Ok(path) = self.input.add.try_recv() {
            self.output.output.send(CoreAction::Add(CoreActionAdd{
                name: "main".into(),
                comp: path.0,
            }))?;
        }
        if let Ok(_) = self.input.halt.try_recv() {
            self.output.output.send(CoreAction::Halt)?;
        }
        Ok(End)
    }
}
