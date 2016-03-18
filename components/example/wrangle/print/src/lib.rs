extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("quadruple.rs");
}
use contract_capnp::quadruple;

component! {
    example_wrangle_stats,
    inputs(input: quadruple),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
// print mean, average, min, max

        Ok(())
    }
}

