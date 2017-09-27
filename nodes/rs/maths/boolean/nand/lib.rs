#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  rsinput(a: bool, b: bool),
  rsinarr(test: i32),
  rsoutput(output: bool),
  rsoutarr(boum: bool),
  fn run(&mut self) -> Result<Signal> {
    let mut sum = 0;
    for (_id, elem) in &self.rsinarr.test {
      sum += elem.recv()?;   
    }
    let a = self.rsinput.a.recv()?;
    let b = self.rsinput.b.recv()?;
    let res = ! (a && b);
    self.rsoutput.output.send(res)?;
    Ok(End)
  }
}
