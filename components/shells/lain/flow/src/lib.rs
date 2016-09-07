#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    shells_lain_flow, contracts(list_text, file_desc)
    inputs(input: list_text),
    inputs_array(),
    outputs(output: file_desc),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = self.ports.recv("input")?;
        let mut flow = String::from("");
        let input_reader: list_text::Reader = ip_input.get_root()?;
        let mut cmd_iterator = input_reader.get_texts()?;
        let mut count = cmd_iterator.iter().count();
        let mut i :usize = 0;
        for cmd in cmd_iterator.iter() {
            if count == 1 {
                flow.push_str(format!("{}_{}({})", cmd?, i, cmd?).as_str());
            } else {
                if count > 1 && i == 0 {
                    flow.push_str(format!("{}_{}({}) output -> ", cmd?, i, cmd?).as_str());
                } else {
                    if (count - 1) == i {
                        flow.push_str(format!("input {}_{}({})", cmd?, i, cmd?).as_str());
                    } else {
                        flow.push_str(format!("input {}_{}({}) output -> ", cmd?, i, cmd?).as_str());
                    }
                }
            }
            i += 1;
        }

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
