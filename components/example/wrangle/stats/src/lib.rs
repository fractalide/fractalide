extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_triple.rs");
    include!("quadruple.rs");
}
use contract_capnp::list_triple;
use contract_capnp::quadruple;

component! {
    example_wrangle_stats,
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: quadruple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
// calculate mean, average, min, max

        Ok(())
    }
}

