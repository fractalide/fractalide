extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    app_model, edges(generic_text)
    inputs(input: any, result: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(compute: any),
    option(),
    acc(any),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));
        let ip_acc = try!(self.ports.recv("acc"));

        if ip_input.action == "get_model" {
            let action = {
                let mut reader: generic_text::Reader = try!(ip_input.read_schema());
                try!(reader.get_text()).to_string()
            };
            let mut new_ip = ip_acc.clone();
            new_ip.action = action;
            try!(self.ports.send("output", new_ip));
            try!(self.ports.send("acc", ip_acc));
        } else if ip_input.action == "create" {
            try!(self.ports.send("acc", ip_input));
        } else {
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
        }

        Ok(())
    }
}
