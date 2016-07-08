extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_growing_flex, contracts(js_create, generic_text, fbp_action)
    inputs(input: any),
    inputs_array(),
    outputs(output: any, scheduler: fbp_action),
    outputs_array(output: any),
    option(generic_text),
    acc(), portal(usize => 0)
    fn run(&mut self) -> Result<()> {

        let mut ip = try!(self.ports.recv("input"));
        match &ip.action[..] {
            "create" => {
                // Send the create comp IP
                let mut send_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = send_ip.init_root();
                    let mut add = builder.init_add();
                    add.set_name("flex");
                    add.set_comp("ui_js_flex");
                }
                try!(self.ports.send("scheduler", send_ip));
                // Connect to outside
                let mut connect_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = connect_ip.init_root();
                    let mut connect = builder.init_connect_sender();
                    connect.set_name("flex");
                    connect.set_port("output");
                    connect.set_output("flex");
                }
                try!(self.ports.send("scheduler", connect_ip));

                // Send the acc IP
                let mut send_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = send_ip.init_root();
                    let mut connect = builder.init_send();
                    connect.set_comp("flex");
                    connect.set_port("input");
                }
                try!(self.ports.send("scheduler", send_ip));
                try!(self.ports.send("scheduler", ip));

            }
            "remove" => {
                if self.portal > 0 {
                    let name = format!("i{}", self.portal);

                    // Send the delete IP
                    let mut send_ip = IP::new();
                    {
                        let mut builder: fbp_action::Builder = send_ip.init_root();
                        let mut connect = builder.init_send();
                        connect.set_comp(&name);
                        connect.set_port("input");
                    }
                    try!(self.ports.send("scheduler", send_ip));
                    let mut comp_ip = IP::new();
                    comp_ip.action = "delete".into();
                    try!(self.ports.send("scheduler", comp_ip));


                    // TODO : remove the sleep once scheduler.remove_comp is async
                    thread::sleep_ms(50);
                    // Send the remove IP
                    let mut remove_ip = IP::new();
                    {
                        let mut builder: fbp_action::Builder = remove_ip.init_root();
                        let mut rem = builder.set_remove(&name);
                    }
                    try!(self.ports.send("scheduler", remove_ip));

                    self.portal -= 1;
                }
            },
            "add" => {
                self.portal += 1;
                // Add link
                let mut ip_opt = self.recv_option();
                let mut reader: generic_text::Reader = try!(ip_opt.get_root());
                let name = format!("i{}", self.portal);
                // Send the create comp IP
                let mut send_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = send_ip.init_root();
                    let mut add = builder.init_add();
                    add.set_name(&name);
                    add.set_comp(try!(reader.get_text()));
                }
                try!(self.ports.send("scheduler", send_ip));

                // Send the connect IP
                let mut send_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = send_ip.init_root();
                    let mut connect = builder.init_connect();
                    connect.set_o_name(&name);
                    connect.set_o_port("output");
                    connect.set_i_name("flex");
                    connect.set_i_port("places");
                    connect.set_i_selection(&name)
                }
                try!(self.ports.send("scheduler", send_ip));

                // Send the create IP
                let mut send_ip = IP::new();
                {
                    let mut builder: fbp_action::Builder = send_ip.init_root();
                    let mut send = builder.init_send();
                    send.set_comp(&name);
                    send.set_port("input");
                }
                try!(self.ports.send("scheduler", send_ip));
                ip.action = "create".into();
                try!(self.ports.send("scheduler", ip));
            }
            _ => { try!(self.ports.send_action("output", ip)); }
        };
        Ok(())
    }
}
