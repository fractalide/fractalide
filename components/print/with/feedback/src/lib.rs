extern crate capnp;

#[macro_use]
extern crate rustfbp;

mod contracts_capnp {
    include!("path.rs");
    include!("value_string.rs");
}
use contracts_capnp::value_string;
use contracts_capnp::path;

component! {
    print_with_feedback,
    inputs(input: path),
    inputs_array(),
    outputs(next: value_string),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip = try!(self.ports.recv("input"));
        let path = try!(ip.get_reader());
        let path: path::Reader = try!(path.get_root());
        let path = try!(path.get_path());

        println!("wtf {:?}", path);

        if path != "end" {
            let mut next_ip = capnp::message::Builder::new_default();
            {
                let mut ip = next_ip.init_root::<value_string::Builder>();
                ip.set_value("next");
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&next_ip));
            try!(self.ports.send("next", send_ip));
        }
        Ok(())

    }

}
