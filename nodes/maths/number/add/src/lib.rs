#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  inarr(numbers: maths_number),
  output(output: number),
  fn run(&mut self) -> Result<Signal> {
    let mut acc = 0;
    for recv in self.inarr.numbers.values() {
        let mut msg = try!(recv.recv());
        let m: maths_number::Reader = try!(msg.read_schema());
        let n = m.get_number();
        acc += n;
    }
    let mut new_m = Msg::new();
    {
      let mut number = new_m.build_schema::<maths_number::Builder>();
      number.set_number(acc);
    }
    try!(self.output.output.send(new_m));

    Ok(End)
  }
}
