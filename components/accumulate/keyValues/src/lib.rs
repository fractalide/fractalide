extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts {
  include!("key_value.rs");
}
use contracts::key_value;

component! {
  AccumulateKeyValues,
  inputs(input: key_value),
  inputs_array(),
  outputs(output: key_value),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
    let mut acc = 0;
    loop {
      let mut ip = try!(self.ports.recv("input"));
      let kv = try!(ip.get_reader());
      let kv: key_value::Reader = try!(kv.get_root());
      let k = kv.get_key();
      let v = kv.get_value();
      acc += v;
    }
    println!("Total: {}", acc);
    Ok(())
  }
}
