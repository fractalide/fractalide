#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: prim_u64),
    output(output: prim_u64),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_input = self.input.input.recv()?;
        {
            let mut builder = msg_input.edit_schema::<prim_u64::Builder, prim_u64::Reader>()?;
            let actual = builder.borrow().as_reader().get_u64();
            builder.set_u64(actual+1);
        }
        let _ = self.output.output.send(msg_input);
        Ok(End)
    }
}
