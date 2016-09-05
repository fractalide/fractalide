#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    shells_lain_flow, contracts(generic_text, list_text)
    inputs(input: list_text),
    inputs_array(),
    outputs(output: generic_text),
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
                flow.push_str(format!("{}({})", cmd?, cmd?).as_str());
            } else {
                if count > 1 && i == 0 {
                    flow.push_str(format!("{}({}) output -> ", cmd?, cmd?).as_str());
                } else {
                    if (count - 1) == i {
                        flow.push_str(format!("input {}({})", cmd?, cmd?).as_str());
                    } else {
                        flow.push_str(format!("input {}({}) output -> ", cmd?, cmd?).as_str());
                    }
                }
            }
            i += 1;
        }
        let mut out_ip_output = IP::new();
        {
            let mut variable = out_ip_output.init_root::<generic_text::Builder>();
            variable.set_text(flow.as_str());
        }
        self.ports.send("output", out_ip_output)?;
        Ok(())
    }
}
