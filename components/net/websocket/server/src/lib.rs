#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate ws;

component! {
    Face, contracts(protocol_domain_port)
    inputs( ),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(protocol_domain_port),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = self.recv_option();
        let pdp: protocol_domain_port::Reader = try!(ip.get_root());
        let port = pdp.get_port();
        let domain = pdp.get_domain();
        let pdp = format!("{}:{}",try!(domain),port);
        env_logger::init().unwrap();
        if let Err(error) = listen("127.0.0.1:3012", |out| {
            move |msg| {
                println!("Server got message '{}'. ", msg);
                out.send(msg)
            }
        }) {
            println!("Failed to create WebSocket due to {:?}", error);
        }
        Ok(())
    }
}
