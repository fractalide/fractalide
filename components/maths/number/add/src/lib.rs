extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("maths_number.rs");
}
use self::contract_capnp::maths_number;

component! {
  Add,
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
