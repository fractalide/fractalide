extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contracts_capnp {
    include!("file_list.rs");
    include!("path.rs");
    include!("value_string.rs");
}
use contracts_capnp::file_list;
use contracts_capnp::path;
use contracts_capnp::value_string;

component! {
    example_wrangle_processchunk_iterate_paths,
    inputs(input: file_list, next: value_string),
    inputs_array(),
    outputs(output: path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        Ok(())
    }
}

