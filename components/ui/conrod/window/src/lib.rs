extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_conrod_window,
    inputs(input: any),
    inputs_array(),
    outputs(output: any, magic: any),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let ip_a = try!(self.ports.recv("input"));

        let _ = self.ports.send_action("output", ip_a);

        let mut new_ip = IP::new();
        new_ip.origin = "-button".to_string();
        self.ports.send("magic", new_ip);

        let mut new_ip = IP::new();
        new_ip.origin = "-button".to_string();
        self.ports.send("magic", new_ip);

        let mut new_ip = IP::new();
        new_ip.origin = "-button".to_string();
        new_ip.action = "button_clicked".into();
        self.ports.send("magic", new_ip);

        Ok(())
    }
}
