
#![feature(braced_empty_structs)]
extern crate capnp;

#[macro_use]
extern crate rustfbp;

use rustfbp::component::*;

mod maths_boolean {
    include!("maths_boolean.rs");
}
use self::maths_boolean::boolean;

component! {
  Nand,
  inputs(a: boolean, b: boolean),
  inputs_array(),
  outputs(output: boolean),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut ip_a = try!(self.ports.recv("a".into()));
    let mut ip_b = try!(self.ports.recv("b".into()));
    let a_reader = try!(ip_a.get_reader());
    let b_reader = try!(ip_b.get_reader());
    let a_reader: boolean::Reader = try!(a_reader.get_root());
    let b_reader: boolean::Reader = try!(b_reader.get_root());
    let a = a_reader.get_boolean();
    let b = b_reader.get_boolean();
    let mut new_out = capnp::message::Builder::new_default();
    {
      let mut boolean = new_out.init_root::<boolean::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }
    ip_a.write_builder(&new_out);
    try!(self.ports.send("output".into(), ip_a));
    Ok(())
  }
}
