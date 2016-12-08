extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    app_counter_create, edges(app_counter, js_create)
    inputs(input: app_counter),
    inputs_array(),
    outputs(label: js_create, delta: js_create, plus:js_create, minus:js_create, td: js_create, lr: js_create),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let mut ip_input = try!(self.ports.recv("input"));

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(ip_input.read_schema());
            (reader.get_value(), reader.get_delta())
        };

        let mut ip = IP::new();
        // Plus button
        {
            let mut builder = ip.build_schema::<js_create::Builder>();
            builder.set_type("button");
            builder.set_text("+");
        }
        ip.action = "create".into();
        try!(self.ports.send("plus", ip));

        // Minus button
        let mut ip = IP::new();
        {
            let mut builder = ip.build_schema::<js_create::Builder>();
            builder.set_type("button");
            builder.set_text("-");
        }
        ip.action = "create".into();
        try!(self.ports.send("minus", ip));

        // td
        let mut ip = IP::new();
        {
            let mut builder = ip.build_schema::<js_create::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_style(2);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_val("flex");
                css.borrow().get(1).set_key("flex-direction");
                css.borrow().get(1).set_val("column");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("td", ip));

        // lr
        let mut ip = IP::new();
        {
            let mut builder = ip.build_schema::<js_create::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_style(1);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_val("flex");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("lr", ip));

        // label
        let mut ip = IP::new();
        {
            let mut builder = ip.build_schema::<js_create::Builder>();
            builder.set_type("span");
            builder.set_text(&format!("{}", number));
            {
                let mut css = builder.borrow().init_style(1);
                css.borrow().get(0).set_key("margin");
                css.borrow().get(0).set_val("0 10px");
            }
        }
        ip.action = "create".into();
        try!(self.ports.send("label", ip));

        let mut new_ip = IP::new();
        {
            let mut builder = new_ip.build_schema::<js_create::Builder>();
            builder.set_type("input");
            {
                let mut attr = builder.borrow().init_property(1);
                attr.borrow().get(0).set_key("value");
                attr.borrow().get(0).set_val(&format!("{}", delta));
            }
            {
                let mut style = builder.borrow().init_style(1);
                style.borrow().get(0).set_key("width");
                style.borrow().get(0).set_val("90px");
            }
        }
        new_ip.action = "create".into();
        try!(self.ports.send("delta", new_ip));


        Ok(())
    }
}
