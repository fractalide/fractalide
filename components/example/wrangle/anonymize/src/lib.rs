extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_triple.rs");
}
use contract_capnp::list_triple;

component! {
    example_wrangle_anonymize,
    inputs(input: list_triple),
    inputs_array(),
    outputs(output: list_triple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
// remove results that have less than 6 users

        Ok(())
    }
}

