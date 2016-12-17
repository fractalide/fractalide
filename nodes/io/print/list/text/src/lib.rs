#![feature(question_mark)]
#[macro_use]
extern crate rustfbp;
extern crate capnp;

agent! {
    input(input: list_text),
    output(output: list_text),
    fn run(&mut self) -> Result<Signal> {

        let mut msg_input = self.input.input.recv()?;
        let input = {
            let input_reader: list_text::Reader = msg_input.read_schema()?;
            input_reader.get_texts()
        };

        let mut out_msg_output = Msg::new();
        {
            let msg = out_msg_output.build_schema::<list_text::Builder>();
            let mut texts = msg.init_texts(input?.len() as u32);
            let mut i: u32 = 0;
            for cmd in input?.iter() {
                println!("{:?}", cmd? );
                texts.borrow().set(i, cmd?);
                i += 1;
            }
        }
        let _ = self.output.output.send(out_msg_output)?;
        Ok(End)
    }
}
