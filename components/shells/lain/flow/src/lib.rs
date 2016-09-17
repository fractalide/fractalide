#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    shells_lain_flow, contracts(list_list_list_text, file_desc)
    inputs(input: list_list_list_text),
    inputs_array(),
    outputs(output: file_desc),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let mut flow = String::from("");
        let input_reader: list_list_list_text::Reader = ip_input.get_root()?;
        let mut row_iterator = input_reader.borrow().get_list()?;
        let mut row_count :usize = 0;
        for row in row_iterator.iter() {
            let mut column_count :usize = 0;
            let mut column_iterator = row.borrow().get_list()?;
            for column in column_iterator.iter() {
                let mut arg_count :usize = 0;
                let mut arg_iterator = column.borrow().get_texts()?;
                for arg in arg_iterator.iter() {
                    println!("{:?}", arg? );
                }
                column_count += 1;
            }
            row_count += 1;
        }
        //
        // for row in row_iterator.iter() {
        //     if count == 1 {
        //         flow.push_str(format!("{0}_{1}({0})", row?, i).as_str());
        //     } else {
        //         if count > 1 && i == 0 {
        //             flow.push_str(format!("{0}_{1}({0}) output -> ", row?, i).as_str());
        //         } else {
        //             if (count - 1) == i {
        //                 flow.push_str(format!("input {0}_{1}({0})", row?, i).as_str());
        //             } else {
        //                 flow.push_str(format!("input {0}_{1}({0}) output -> ", row?, i).as_str());
        //             }
        //         }
        //     }
        //     i += 1;
        // }

        // Send start
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_start("flowscript");
        }
        self.ports.send("output", new_ip)?;

        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_text(&flow.as_str());
        }
        self.ports.send("output", new_ip)?;

        // Send stop
        let mut new_ip = IP::new();
        {
            let mut ip = new_ip.init_root::<file_desc::Builder>();
            ip.set_end("flowscript");
        }
        self.ports.send("output", new_ip)?;
        Ok(())
    }
}
