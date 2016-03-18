
extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_triple.rs");
}
use contract_capnp::list_triple;

component! {
    example_wrangle_aggregate_triple,
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: list_triple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
   // receive "start"
   // receive stream of kvs (airline, priceX, 3), (airline, priceY, 5), (airline, priceX, 8)
   // aggregate (airline, priceX, 11) (airline, priceY, 5)
   // receive "stop"
   // send aggregated list out

        Ok(())
    }
}

