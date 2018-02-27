#[macro_use]
extern crate rustfbp;
extern crate capnp;
#[macro_use]
extern crate log;

agent! {
  fn run(&mut self) -> Result<Signal> {
      debug!("{:?}", env!("CARGO_PKG_NAME"));
      println!("This node combines all schema together to ensure there are no name collisions.", );
      Ok(End)
  }
}
