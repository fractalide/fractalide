extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    app_counter_create, contracts(app_counter, js_tag)
    inputs(input: app_counter),
    inputs_array(),
    outputs(label: js_tag, delta: js_tag, plus:js_tag, minus:js_tag, td: js_tag, lr: js_tag),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(ip_input.get_root());
            (reader.get_value(), reader.get_delta())
        };

        let mut ip = IP::new();
        // Plus button
        {
            let mut builder = ip.init_root::<js_tag::Builder>();
            builder.set_type("button");
            builder.set_content("+");
        }
        ip.action = "create".into();
        try!(self.ports.send("plus", ip));

        // Minus button
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_tag::Builder>();
            builder.set_type("button");
            builder.set_content("-");
        }
        ip.action = "create".into();
        try!(self.ports.send("minus", ip));

        // td
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_tag::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_css(2);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_value("flex");
                css.borrow().get(1).set_key("flex-direction");
                css.borrow().get(1).set_value("column");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("td", ip));

        // lr
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_tag::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_css(1);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_value("flex");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("lr", ip));

        // label
        let mut ip = IP::new();
        {
            let mut builder = ip.init_root::<js_tag::Builder>();
            builder.set_type("span");
            builder.set_content(&format!("{}", number));
            {
                let mut css = builder.borrow().init_css(1);
                css.borrow().get(0).set_key("margin");
                css.borrow().get(0).set_value("0 10px");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("label", ip));

        let mut new_ip = IP::new();
        {
            let mut builder = new_ip.init_root::<js_tag::Builder>();
            builder.set_type("input");
            {
                let mut attr = builder.borrow().init_attributes(1);
                attr.borrow().get(0).set_key("value");
                attr.borrow().get(0).set_value(&format!("{}", delta));
            }
        }
        new_ip.action = "create".into();
        try!(self.ports.send("delta", new_ip));


        Ok(())
    }
}
