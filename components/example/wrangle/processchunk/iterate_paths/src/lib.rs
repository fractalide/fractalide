extern crate capnp;

#[macro_use]
extern crate rustfbp;
mod contracts_capnp {
    include!("file_list.rs");
    include!("path.rs");
    include!("value_string.rs");
}
use contracts_capnp::file_list;
use contracts_capnp::path;
use contracts_capnp::value_string;

component! {
    example_wrangle_processchunk_iterate_paths,
    inputs(input: file_list, next: value_string),
    inputs_array(),
    outputs(output: path),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let list = try!(ip.get_reader());
        let list: file_list::Reader = try!(list.get_root());
        let list = try!(list.get_files());
        for i in 0..list.len()
        {
            let mut new_ip = capnp::message::Builder::new_default();
            {
                let mut ip = new_ip.init_root::<path::Builder>();
                ip.set_path(try!(list.get(i)));
            }
            let mut send_ip = IP::new();
            try!(send_ip.write_builder(&new_ip));
            try!(self.ports.send("output", send_ip));

            let mut ip = try!(self.ports.recv("next"));
        }

        let mut end_ip = capnp::message::Builder::new_default();
        {
            let mut ip = end_ip.init_root::<path::Builder>();
            ip.set_path("end");
        }
        let mut send_ip = IP::new();
        try!(send_ip.write_builder(&end_ip));
        try!(self.ports.send("output", send_ip));
        Ok(())
    }
}

