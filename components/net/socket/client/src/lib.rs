extern crate capnp;

#[macro_use]
extern crate rustfbp;

#![feature(io)]
#![feature(core)]
#![feature(path)]
#![feature(env)]

use std::env;
use common::SOCKET_PATH;
use std::old_io::net::pipe::UnixStream;


mod contracts {
    include!("protocol_domain_port.rs");
}
use self::contracts::protocol_domain_port;

component! {
    Face,
    inputs( input: any, config: protocol_domain_port ),
    inputs_array(),
    outputs(),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        pub static SOCKET_PATH: &'static str = "loopback-socket";
        // `args` returns the arguments passed to the program
        let args: Vec<String> = env::args().map(|x| x.to_string())
        .collect();
        let socket = Path::new(SOCKET_PATH);

        // First argument is the message to be sent
        let message = match args.as_slice() {
            [_, ref message] => message.as_slice(),
            _ => panic!("wrong number of arguments"),
        };

        // Connect to socket
        let mut stream = match UnixStream::connect(&socket) {
            Err(_) => panic!("server is not running"),
            Ok(stream) => stream,
        };

        // Send message
        match stream.write_str(message) {
            Err(_) => panic!("couldn't send message"),
            Ok(_) => {}
        }
        Ok(())
    }
