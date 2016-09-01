#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
    shells_fsh_generator_nix, contracts(generic_text, list_text)
    inputs(input: list_text),
    inputs_array(),
    outputs(output: generic_text),
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
          let mut variable = out_ip_output.init_root::<generic_text::Builder>();
          variable.set_text("generated nix subnet code!");
        }
        self.ports.send("output", out_ip_output)?;
        Ok(())
    }
}
