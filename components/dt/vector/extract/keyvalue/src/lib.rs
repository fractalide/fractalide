extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contract_capnp {
    include!("list_tuple.rs");
    include!("value_string.rs");
}
use contract_capnp::list_tuple;
use contract_capnp::value_string;

component! {
    DtVectorExtractKeyValue,
    inputs(input: list_tuple),
    inputs_array(),
    outputs(),
    outputs_array(output: list_tuple),
    option(value_string),
    acc(),
    fn run(&mut self) -> Result<()> {

        Ok(())
    }
}
