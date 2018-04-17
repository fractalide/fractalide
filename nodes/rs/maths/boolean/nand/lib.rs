#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate log;

agent! {
  input(a: bool, b: bool),
  inarr(test: i32),
  output(output: bool),
  outarr(boum: usize),
  fn run(&mut self) -> Result<Signal> {
      debug!("{:?}", env!("CARGO_PKG_NAME"));
      let mut sum = 0;
      for (_id, elem) in &self.inarr.test {
          sum += elem.recv::<i32>()?;
      }
      let a = self.input.a.recv()?;
      let b = self.input.b.recv()?;
      let res = ! (a && b);
      self.output.output.send::<bool>(res)?;
      Ok(End)
  }
}
