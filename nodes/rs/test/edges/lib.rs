#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  fn run(&mut self) -> Result<Signal> {
      println!("This node combines all schema together to ensure there are no name collisions.", );
    Ok(End)
  }
}
