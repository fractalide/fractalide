
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
    let a_reader = try!(ip_a.get_reader());
    let b_reader = try!(ip_b.get_reader());
    let a_reader: maths_boolean::Reader = try!(a_reader.get_root());
    let b_reader: maths_boolean::Reader = try!(b_reader.get_root());
    let a = a_reader.get_boolean();
    let b = b_reader.get_boolean();
    let mut new_out = capnp::message::Builder::new_default();
    {
      let mut boolean = new_out.init_root::<maths_boolean::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }
    ip_a.write_builder(&new_out);
    try!(self.ports.send("output", ip_a));
    Ok(())
  }
}
