extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contract_capnp {
    include!("list_tuple.rs");
    include!("file_desc.rs");
}
use contract_capnp::list_tuple;
use contract_capnp::file_desc;

component! {
    example_wrangle_processchunk_convert_json_vector,
    inputs(input: file_desc),
    inputs_array(),
    outputs(output: list_tuple),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        Ok(())
    }
}

