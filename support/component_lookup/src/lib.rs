extern crate capnp;

#[macro_use]
extern crate rustfbp;

fn get(name: &str) -> Option<&str> {
    match name {
        nix-replace-me
        _ => None,
    }
}
component! {
    component_lookup, contracts(path, option_path)
    inputs(input: path),
    inputs_array(),
    outputs(output: option_path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let name: path::Reader = try!(ip.get_root());

        let new_path = get(try!(name.get_path()));

        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<option_path::Builder>();
            match new_path {
                None => { ip.set_none(()) },
                Some(p) => { ip.set_path(p) }
            };
        }
        let _ = self.ports.send("output", new_ip);
        Ok(())
    }

}
