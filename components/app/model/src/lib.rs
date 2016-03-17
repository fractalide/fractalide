extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_model,
    inputs(input: any, result: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(compute: any),
    option(),
    acc(any),
    fn run(&mut self) -> Result<()> {
        let ip_input = try!(self.ports.recv("input"));
        let ip_acc = try!(self.ports.recv("acc"));
        
        let action: &str = &ip_input.action.clone();
        let send = self.ports.send_array("compute", action, ip_input);
        if let Ok(_) = send {
            try!(self.ports.send_array("compute", action, ip_acc));
            let ip_new_acc = try!(self.ports.recv("result"));
            let mut ip_out = ip_new_acc.clone();
            ip_out.action = "model".into();
            try!(self.ports.send("output", ip_out));
            try!(self.ports.send("acc", ip_new_acc));
        } else {
            try!(self.ports.send("acc", ip_acc));
        }

        Ok(())
    }
}
