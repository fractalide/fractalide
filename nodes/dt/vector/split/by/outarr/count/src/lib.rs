#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: file_list),
    outarr(output: file_list),
    fn run(&mut self) -> Result<Signal> {
        let mut msg = try!(self.input.input.recv());
        let list: file_list::Reader = try!(msg.read_schema());
        let list = try!(list.get_files());

        let mut v = Vec::with_capacity(list.len() as usize);
        for path in 0..list.len()
        {
            v.push(try!(list.get(path)));
        }
        let out_array_count = self.outarr.output.keys().count();
        let inc_by = list.len() as usize / out_array_count ;
        let mut i: u32 = 0;
        for chunk in v.chunks(inc_by)
        {
            let mut new_msg = Msg::new();
            {
                let msg = new_msg.build_schema::<file_list::Builder>();
                let mut files = msg.init_files(chunk.len() as u32);
                let mut i: u32 = 0;
                for path in chunk {
                    files.borrow().set(i, path);
                    i += 1;
                }
            }
            if let Some(sender) = self.outarr.output.get(&format!("{}", i)){
                try!(sender.send(new_msg));
            }
            i += 1;
        }
        Ok(End)
    }
}
