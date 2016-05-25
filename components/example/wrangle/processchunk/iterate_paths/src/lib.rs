#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    example_wrangle_processchunk_iterate_paths, contracts(file_list, path, value_string)
    inputs(input: file_list, next: value_string),
    inputs_array(),
    outputs(output: path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let list: file_list::Reader = try!(ip.get_root());
        let list = try!(list.get_files());
        for i in 0..list.len()
        {
            let mut new_ip = IP::new();
            {
                let mut ip = new_ip.init_root::<path::Builder>();
                ip.set_path(try!(list.get(i)));
            }
            try!(self.ports.send("output", new_ip));
            let mut ip = try!(self.ports.recv("next"));
        }

        let mut end_ip = IP::new();
        {
            let mut ip = end_ip.init_root::<path::Builder>();
            ip.set_path("end");
        }
        try!(self.ports.send("output", end_ip));
        Ok(())
    }
}
