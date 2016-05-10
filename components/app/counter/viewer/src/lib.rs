extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_counter_viewer, contracts(generic_text, app_counter)
    inputs(input: app_counter),
    inputs_array(),
    outputs(label: generic_text, delta: generic_text),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(ip_input.get_root());
            (reader.get_value(), reader.get_delta())
        };
        {
            let mut builder = ip_input.init_root::<generic_text::Builder>();
            builder.set_text(&format!("{}", number));
        }
        ip_input.action = "set_label".into();
        try!(self.ports.send("label", ip_input));

        let mut new_ip = IP::new();
        {
            let mut builder = new_ip.init_root::<generic_text::Builder>();
            builder.set_text(&format!("{}", delta));
        }
        new_ip.action = "set_label".into();
        try!(self.ports.send("delta", new_ip));


        Ok(())
    }
}
