
#![feature(braced_empty_structs)]
extern crate capnp;

#[macro_use]
extern crate rustfbp;

use rustfbp::component::*;

component! {
  Nand,
  inputs(a: boolean, b: boolean),
  inputs_array(),
  outputs(output: boolean),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) {
    let mut ip_a = self.ports.recv("a".into()).expect("cannot receive");
    let mut ip_b = self.ports.recv("b".into()).expect("cannot receive");
    let a_reader = ip_a.get_reader().expect("cannot get reader");
    let b_reader = ip_b.get_reader().expect("cannot get reader");
    let a_reader: boolean::Reader = a_reader.get_root().expect("not a boolean reader");
    let b_reader: boolean::Reader = b_reader.get_root().expect("not a boolean reader");
    let a = a_reader.get_boolean();
    let b = b_reader.get_boolean();
    let mut new_out = super::capnp::message::Builder::new_default();
    {
      let mut boolean = new_out.init_root::<boolean::Builder>();
      boolean.set_boolean(if a == true && b == true {false} else {true});
    }
    ip_a.write_builder(&new_out);
    self.ports.send("output".into(), ip_a).expect("cannot send date");
  }

  mod boolean_capnp {
    include!("maths_boolean_capnp.rs");
  }
  use self::boolean_capnp::boolean;
}
