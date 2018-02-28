extern crate capnp;
#[macro_use]
extern crate log;

#[macro_use]
extern crate rustfbp;
extern crate env_logger;

agent! {
    input(input: bool),
    output(output: bool),
    fn run(&mut self) -> Result<Signal> {
        env_logger::try_init();
        debug!("{:?}", env!("CARGO_PKG_NAME"));
        let a: bool = self.input.input.recv()?;
        println!("boolean : {}", a);
        let _ = self.output.output.send::<bool>(a);
        Ok(End)
    }
}
