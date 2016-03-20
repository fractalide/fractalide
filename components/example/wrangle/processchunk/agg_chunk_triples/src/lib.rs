
extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
  include!("list_triple.rs");
  include!("value_string.rs");
}
use contract_capnp::list_triple;
use contract_capnp::value_string;
use std::str::FromStr;

component! {
    example_wrangle_aggregatechunks,
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: list_triple, next : value_string),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        Ok(())
    }
}

