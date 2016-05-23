extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_growing_block, contracts(js_create, js_block, generic_text, fbp_action)
    inputs(input: any),
    inputs_array(),
    outputs(output: any, scheduler: fbp_action),
    outputs_array(output: any),
    option(js_growing_block),
    acc(),
    fn run(&mut self) -> Result<()> {

        let mut index: usize = 0;
        // Send the create comp IP
        let mut send_ip = IP::new();
        {
            let mut builder: fbp_action::Builder = send_ip.init_root();
            let mut add = builder.init_add();
            add.set_name("td");
            add.set_comp("ui_js_block");
        }
        try!(self.ports.send("scheduler", send_ip));
        // Connect to outside
        let mut connect_ip = IP::new();
        {
            let mut builder: fbp_action::Builder = connect_ip.init_root();
            let mut connect = builder.init_connect_sender();
            connect.set_name("-td");
            connect.set_port("output");
            connect.set_output("td");
        }
        try!(self.ports.send("scheduler", connect_ip));

        // Send the acc IP
        let mut send_ip = IP::new();
        {
            let mut builder: fbp_action::Builder = send_ip.init_root();
            let mut connect = builder.init_send();
            connect.set_comp("-td");
            connect.set_port("acc");
        }
        try!(self.ports.send("scheduler", send_ip));
        let mut acc_ip = IP::new();
        {
            let mut builder: js_block::Builder = acc_ip.init_root();
            builder.set_css("display: flex; flex-direction: column");
            builder.init_places(0);
        }
        try!(self.ports.send("scheduler", acc_ip));

        loop {
            let ip = try!(self.ports.recv("input"));
            match &ip.action[..] {
                "remove" => {
                    if index > 0 {
                        let name = format!("{}", index);

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

                        index -= 1;
                    }
                },
                "add" => {
                    index += 1;
                    // Add link
                    let mut ip_opt = self.recv_option();
                    let mut reader: generic_text::Reader = try!(ip_opt.get_root());
                    let name = format!("{}", index);
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
                        connect.set_i_name("-td");
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
                    let mut comp_ip = IP::new();
                    comp_ip.action = "create".into();
                    try!(self.ports.send("scheduler", comp_ip));
                }
                _ => { try!(self.ports.send_action("output", ip)); }
            };
            if index == 0 { break; }
        };

        Ok(())
    }
}
