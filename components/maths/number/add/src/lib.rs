extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod maths_number {
    include!("maths_number.rs");
}
use self::maths_number::number;

component! {
  Add,
  inputs(),
  inputs_array(numbers: number),
  outputs(output: number),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut acc = 0;
    for ins in try!(self.ports.get_input_selections("numbers")) {
      let mut ip = try!(self.ports.recv_array("numbers", &ins));
      let mut m = try!(ip.get_reader());
      let m: number::Reader = try!(m.get_root());
      let n = m.get_number();
      acc += n;
    }
    let mut new_m = capnp::message::Builder::new_default();
    {
      let mut number = new_m.init_root::<number::Builder>();
      number.set_number(acc);
    }
    let mut ip = IP::new();
    try!(ip.write_builder(&new_m));
    try!(self.ports.send("output", ip));

    Ok(())
  }
}
