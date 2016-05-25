#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate ws;
extern crate env_logger;

use ws::{connect, CloseCode};

component! {
    net_websocket_client, contracts(protocol_domain_port)
    inputs( start: protocol_domain_port, input: any ),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(protocol_domain_port),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.try_recv("start"));
        let mut ip = self.recv_option();
        let pdp: protocol_domain_port::Reader = try!(ip.get_root());
        let protocol = pdp.get_protocol();
        let domain = pdp.get_domain();
        let port = pdp.get_port();
        let ip = try!(self.ports.try_recv("input"));
        env_logger::init().unwrap();
        if let Err(error) = connect("ws://127.0.0.1:3012", |out| {
            if let Err(_) = out.send("Hello WebSocket") {
                println!("Websocket couldn't queue an initial message.")
            } else {
                println!("Client sent message 'Hello WebSocket'. ")
            }
            move |msg| {
                println!("Client got message '{}'. ", msg);
                out.close(CloseCode::Normal)
            }
        }) {
            println!("Failed to create WebSocket due to: {:?}", error);
        }
        Ok(())
    }
}
