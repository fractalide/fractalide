
extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
  include!("list_tuple.rs");
  include!("list_triple.rs");
  include!("value_string.rs");
}
use contract_capnp::list_tuple;
use contract_capnp::list_triple;
use contract_capnp::value_string;

component! {
  example_wrangle_aggregatechunks,
  inputs(input: list_tuple),
  inputs_array(),
  outputs(output: list_triple, next : value_string),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {
   // receive "start"
   // receive stream of kvs (airline, priceX), (airline, priceY), (airline, priceX)
   // aggregate (airline, priceX, 2) (airline, priceY, 1)
   // receive "stop"
   // send aggregated list out

   Ok(())
 }
}

