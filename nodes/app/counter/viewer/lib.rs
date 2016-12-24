extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    input(input: app_counter),
    output(label: prim_text, delta: prim_text),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_input = try!(self.input.input.recv());

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(msg_input.read_schema());
            (reader.get_value(), reader.get_delta())
        };
        {
            let mut builder = msg_input.build_schema::<prim_text::Builder>();
            builder.set_text(&format!("{}", number));
        }
        msg_input.action = "set_text".into();
        try!(self.output.label.send(msg_input));

        let mut new_msg = Msg::new();
        {
            let mut builder = new_msg.build_schema::<generic_tuple_text::Builder>();
            builder.set_key("value");
            builder.set_value(&format!("{}", delta));
        }
        new_msg.action = "set_property".into();
        try!(self.output.delta.send(new_msg));


        Ok(End)
    }
}
