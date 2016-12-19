#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
  input(a: maths_boolean, b: maths_boolean),
  output(output: maths_boolean),
  fn run(&mut self) -> Result<Signal> {
    let a = {
        let mut msg_a = try!(self.input.a.recv());
        let a_reader: maths_boolean::Reader = msg_a.read_schema()?;
        a_reader.get_boolean()
    };
    let b = {
        let mut msg_b = try!(self.input.b.recv());
        let b_reader: maths_boolean::Reader = msg_b.read_schema()?;
        b_reader.get_boolean()
    };

    let mut out_msg = Msg::new();
    {
      let mut boolean = out_msg.build_schema::<maths_boolean::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }
    try!(self.output.output.send(out_msg));
    Ok(End)
  }
}
