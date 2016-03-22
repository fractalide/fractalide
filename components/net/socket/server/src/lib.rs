extern crate capnp;

#[macro_use]
extern crate rustfbp;
extern crate nanomsg;

mod contracts {
    include!("protocol_domain_port.rs");
}
use self::contracts::protocol_domain_port;
use nanomsg::{Socket, Protocol};


//the lazy pirate
component! {
    Face,
    inputs( config: protocol_domain_port ),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        Ok(())
    }
}
