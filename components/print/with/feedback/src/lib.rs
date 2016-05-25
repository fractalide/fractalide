#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    print_with_feedback, contracts(path, value_string)
    inputs(input: path),
    inputs_array(),
    outputs(next: value_string),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let path: path::Reader = try!(ip.get_root());
        let path = try!(path.get_path());
        if path != "end" {
            let mut next_ip = IP::new();
            {
                let mut ip = next_ip.init_root::<value_string::Builder>();
                ip.set_value("next");
            }
            try!(self.ports.send("next", next_ip));
        }
        Ok(())
    }
}
