extern crate capnp;

#[macro_use]
extern crate rustfbp;
extern crate nanomsg;

mod contracts {
    include!("protocol_domain_port.rs");
}
use self::contracts::protocol_domain_port;

component! {
    Face,
    inputs( config: protocol_domain_port ),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.try_recv("start"));
        let ip = self.recv_option();
        let pdp = try!(ip.get_reader());
        let pdp: protocol_domain_port::Reader = try!(pdp.get_root());
        let port = pdp.get_port();
        let domain = pdp.get_domain();
        let pdp = format!("{}:{}",try!(domain),port);

        println!("hi");

        env_logger::init().unwrap();
        if let Err(error) = listen("127.0.0.1:3012", |out| {

            // The handler needs to take ownership of out, so we use move
            move |msg| {

                // Handle messages received on this connection
                println!("Server got message '{}'. ", msg);

                // Use the out channel to send messages back
                out.send(msg)
            }
        }) {
            // Inform the user of failure
            println!("Failed to create WebSocket due to {:?}", error);
        }

        Ok(())
    }
}
