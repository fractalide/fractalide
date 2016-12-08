extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    app_counter_viewer, edges(generic_text, app_counter, generic_tuple_text)
    inputs(input: app_counter),
    inputs_array(),
    outputs(label: generic_text, delta: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(ip_input.read_schema());
            (reader.get_value(), reader.get_delta())
        };
        {
            let mut builder = ip_input.build_schema::<generic_text::Builder>();
            builder.set_text(&format!("{}", number));
        }
        ip_input.action = "set_text".into();
        try!(self.ports.send("label", ip_input));

        let mut new_ip = IP::new();
        {
            let mut builder = new_ip.build_schema::<generic_tuple_text::Builder>();
            builder.set_key("value");
            builder.set_value(&format!("{}", delta));
        }
        new_ip.action = "set_property".into();
        try!(self.ports.send("delta", new_ip));


        Ok(())
    }
}
