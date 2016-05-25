#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
  Add, contracts(maths_number)
  inputs(),
  inputs_array(numbers: maths_number),
  outputs(output: number),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut acc = 0;
    for ins in try!(self.ports.get_input_selections("numbers")) {
      let mut ip = try!(self.ports.recv_array("numbers", &ins));
      let m: maths_number::Reader = try!(ip.get_root());
      let n = m.get_number();
      acc += n;
    }
    let mut new_m = IP::new();
    {
      let mut number = new_m.init_root::<maths_number::Builder>();
      number.set_number(acc);
    }
    try!(self.ports.send("output", new_m));

    Ok(())
  }
}
