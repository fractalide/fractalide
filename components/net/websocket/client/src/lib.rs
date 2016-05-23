#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate ws;
extern crate env_logger;

mod contracts {
    include!("protocol_domain_port.rs");
}
use self::contracts::protocol_domain_port;
use ws::{connect, CloseCode};

component! {
    Face,
    inputs( start: protocol_domain_port, input: any ),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(protocol_domain_port),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.try_recv("start"));
        let ip = self.recv_option();
        let pdp = try!(ip.get_reader());
        let pdp: protocol_domain_port::Reader = try!(pdp.get_root());
        let protocol = pdp.get_protocol();
        let domain = pdp.get_domain();
        let port = pdp.get_port();

        let ip = try!(self.ports.try_recv("input"));

        env_logger::init().unwrap();

        if let Err(error) = connect("ws://127.0.0.1:3012", |out| {

            // Queue a message to be sent when the WebSocket is open
            if let Err(_) = out.send("Hello WebSocket") {
                println!("Websocket couldn't queue an initial message.")
            } else {
                println!("Client sent message 'Hello WebSocket'. ")
            }

            // The handler needs to take ownership of out, so we use move
            move |msg| {

                // Handle messages received on this connection
                println!("Client got message '{}'. ", msg);

                // Close the connection
                out.close(CloseCode::Normal)
            }

        }) {
            // Inform the user of failure
            println!("Failed to create WebSocket due to: {:?}", error);
        }
        Ok(())
    }
}
