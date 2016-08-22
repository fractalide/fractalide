#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

component! {
  shells_fsh_build_names, contracts(generic_text)
  inputs(input: generic_text),
  inputs_array(),
  outputs(output: generic_text),
  outputs_array(),
  option(),
  acc(),
  fn run(&mut self) -> Result<()> {

    let mut ip_parse = self.ports.recv("input")?;
    let input = {
        let input_reader: generic_text::Reader = ip_parse.get_root()?;
        input_reader.get_text()
    };

    

    let mut out_ip_output = IP::new();
    {
      let mut variable = out_ip_output.init_root::<generic_text::Builder>();
      variable.set_text(input?);
    }
    self.ports.send("output", out_ip_output)?;
    Ok(())
  }
}
