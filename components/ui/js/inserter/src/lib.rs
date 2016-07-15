extern crate capnp;

#[macro_use]
extern crate rustfbp;

component! {
    ui_js_inserter,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
      let mut ip = try!(self.ports.recv("input"));
        if ip.action == "create" {
          // ip.action is "insert_content" or "forward"
          ip.action = "insert_text".into();
        }
        try!(self.ports.send("output", ip));

        Ok(())
    }
}
