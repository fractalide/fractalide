#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;
extern crate nom;

component! {
    shells_fsh_parse_verify, contracts(list_text)
    inputs(input: list_text),
    inputs_array(),
    outputs(output: list_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let mut ip_input = self.ports.recv("input")?;
        let input = {
            let input_reader: list_text::Reader = ip_input.get_root()?;
            input_reader.get_texts()
        };

        let mut out_ip_output = IP::new();
        {
            let ip = out_ip_output.init_root::<list_text::Builder>();
            let mut commands = ip.init_texts(input?.len() as u32);
            let mut i: u32 = 0;
            for cmd in input?.iter() {
                commands.borrow().set(i, cmd?);
                i += 1;
            }
        }
        self.ports.send("output", out_ip_output)?;
        Ok(())
    }
}
