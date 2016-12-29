#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  input(a: prim_bool, b: prim_bool),
  output(output: prim_bool),
  fn run(&mut self) -> Result<Signal> {
    let a = {
        let mut msg_a = try!(self.input.a.recv());
        let boolean: prim_bool::Reader = msg_a.read_schema()?;
        boolean.get_bool()
    };
    let b = {
        let mut msg_b = try!(self.input.b.recv());
        let boolean: prim_bool::Reader = msg_b.read_schema()?;
        boolean.get_bool()
    };

    let mut out_msg = Msg::new();
    {
      let mut boolean = out_msg.build_schema::<prim_bool::Builder>();
      boolean.set_bool(if a == true && b == true {false} else {true});
    }
    try!(self.output.output.send(out_msg));
    Ok(End)
  }
}
