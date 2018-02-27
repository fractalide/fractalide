#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  inarr(numbers: prim_i64),
  output(output: number),
  fn run(&mut self) -> Result<Signal> {
debug!("{:?}", env!("CARGO_PKG_NAME"));
    let mut acc = 0;
    for recv in self.inarr.numbers.values() {
        let mut msg = try!(recv.recv());
        let m: prim_i64::Reader = try!(msg.read_schema());
        let n = m.get_i64();
        acc += n;
    }
    let mut new_m = Msg::new();
    {
      let mut number = new_m.build_schema::<prim_i64::Builder>();
      number.set_i64(acc);
    }
    try!(self.output.output.send(new_m));

    Ok(End)
  }
}
