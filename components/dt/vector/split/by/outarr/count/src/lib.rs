#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    dt_vector_split_by_outarr_count, contracts(file_list)
    inputs(input: file_list),
    inputs_array(),
    outputs(),
    outputs_array(output: file_list),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip = try!(self.ports.recv("input"));
        let list: file_list::Reader = try!(ip.get_root());
        //let list = try!(ip.get_reader());
        //let list: file_list::Reader = try!(list.get_root());
        let list = try!(list.get_files());

        let mut v =Vec::with_capacity(list.len() as usize);
        for path in 0..list.len()
        {
            v.push(try!(list.get(path)));
        }
        let out_array_count = try!(self.ports.get_output_selections("output")).iter().count();
        let inc_by = list.len() as usize / out_array_count ;
        let mut i: u32 = 0;
        for chunk in v.chunks(inc_by)
        {
            let mut new_ip = IP::new();
            {
                let ip = new_ip.init_root::<file_list::Builder>();
                let mut files = ip.init_files(chunk.len() as u32);
                let mut i: u32 = 0;
                for path in chunk {
                    files.borrow().set(i, path);
                    i += 1;
                }
            }
            try!(self.ports.send_array("output", &format!("{}", i), new_ip));
            i += 1;
        }
        Ok(())
    }
}
