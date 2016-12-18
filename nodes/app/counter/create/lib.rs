extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

agent! {
    input(input: app_counter),
    output(label: js_create, delta: js_create, plus:js_create, minus:js_create, td: js_create, lr: js_create),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_input = try!(self.input.input.recv());

        let (number, delta) = {
            let mut reader: app_counter::Reader = try!(msg_input.read_schema());
            (reader.get_value(), reader.get_delta())
        };

        let mut msg = Msg::new();
        // Plus button
        {
            let mut builder = msg.build_schema::<js_create::Builder>();
            builder.set_type("button");
            builder.set_text("+");
        }
        msg.action = "create".into();
        try!(self.output.plus.send(msg));

        // Minus button
        let mut msg = Msg::new();
        {
            let mut builder = msg.build_schema::<js_create::Builder>();
            builder.set_type("button");
            builder.set_text("-");
        }
        msg.action = "create".into();
        try!(self.output.minus.send(msg));

        // td
        let mut msg = Msg::new();
        {
            let mut builder = msg.build_schema::<js_create::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_style(2);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_val("flex");
                css.borrow().get(1).set_key("flex-direction");
                css.borrow().get(1).set_val("column");
            }
        }
        msg.action = "create".into();
        try!(self.output.td.send(msg));

        // lr
        let mut msg = Msg::new();
        {
            let mut builder = msg.build_schema::<js_create::Builder>();
            builder.set_type("div");
            {
                let mut css = builder.borrow().init_style(1);
                css.borrow().get(0).set_key("display");
                css.borrow().get(0).set_val("flex");
            }
        }
        msg.action = "create".into();
        try!(self.output.lr.send(msg));

        // label
        let mut msg = Msg::new();
        {
            let mut builder = msg.build_schema::<js_create::Builder>();
            builder.set_type("span");
            builder.set_text(&format!("{}", number));
            {
                let mut css = builder.borrow().init_style(1);
                css.borrow().get(0).set_key("margin");
                css.borrow().get(0).set_val("0 10px");
            }
        }
        msg.action = "create".into();
        try!(self.output.label.send(msg));

        let mut new_msg = Msg::new();
        {
            let mut builder = new_msg.build_schema::<js_create::Builder>();
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
        new_msg.action = "create".into();
        try!(self.output.delta.send(new_msg));


        Ok(End)
    }
}
