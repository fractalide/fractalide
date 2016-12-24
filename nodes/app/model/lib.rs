extern crate capnp;

#[macro_use]
extern crate rustfbp;

agent! {
    input(input: any, result: any),
    output(output: any),
    outarr(compute: any),
    accumulator(any),
    fn run(&mut self) -> Result<Signal> {
        let mut msg_input = try!(self.input.input.recv());
        let msg_acc = try!(self.input.input.recv());

        if msg_input.action == "get_model" {
            let action = {
                let mut reader: prim_text::Reader = try!(msg_input.read_schema());
                try!(reader.get_text()).to_string()
            };
            let mut new_msg = msg_acc.clone();
            new_msg.action = action;
            try!(self.output.output.send(new_msg));
            try!(self.output.accumulator.send(msg_acc));
        } else if msg_input.action == "create" {
            try!(self.output.accumulator.send(msg_input));
        } else {
            let action: &str = &msg_input.action.clone();
            let sender = try!(self.outarr.compute.get(action)
                              .ok_or(result::Error::Misc("Unknown element in outarr compute".into())));
            let send = sender.send(msg_input);
            if let Ok(_) = send {
                try!(sender.send(msg_acc));
                let msg_new_acc = try!(self.input.result.recv());
                let mut msg_out = msg_new_acc.clone();
                msg_out.action = "model".into();
                try!(self.output.output.send(msg_out));
                try!(self.output.accumulator.send(msg_new_acc));
            } else {
                try!(self.output.accumulator.send(msg_acc));
            }
        }

        Ok(End)
    }
}
