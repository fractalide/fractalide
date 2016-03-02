extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("maths_boolean.rs");
}
use self::contract_capnp::maths_boolean;

component! {
  Nand,
  inputs(a: maths_boolean, b: maths_boolean),
  inputs_array(),
  outputs(output: maths_boolean),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut ip_a = try!(self.ports.recv("a"));
    let mut ip_b = try!(self.ports.recv("b"));
    let a = {
        let a_reader: maths_boolean::Reader = try!(ip_a.get_root());
        a_reader.get_boolean()
    };
    let b_reader: maths_boolean::Reader = try!(ip_b.get_root());
    let b = b_reader.get_boolean();

    {
      let mut boolean = ip_a.init_root::<maths_boolean::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }

    try!(self.ports.send("output", ip_a));
    Ok(())
  }
}
