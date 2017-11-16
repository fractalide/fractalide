#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  input(a: bool, b: bool),
  inarr(test: i32),
  output(output: bool),
  outarr(boum: usize),
  fn run(&mut self) -> Result<Signal> {
    let mut sum = 0;
    for (_id, elem) in &self.inarr.test {
      sum += elem.recv()?;   
    }
    let a = self.input.a.recv()?;
    let b = self.input.b.recv()?;
    let res = ! (a && b);
    self.output.output.send(res)?;
    Ok(End)
  }
}
