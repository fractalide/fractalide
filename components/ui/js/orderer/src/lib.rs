extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

component! {
    ui_js_orderer, contracts(js_create)
    inputs(),
    inputs_array(places: any),
    outputs(output: any),
    outputs_array(),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        let places = try!(self.ports.get_input_selections("places"));
        for place in places {
            let mut ip_place = self.ports.try_recv_array("places", &place);
            if let Ok(mut ip) = ip_place {
                if ip.action == "create" {
                    ip.action = "insert_text".into();
                    // Add the css
                    let mut vec: Vec<(String, String)> = vec![];
                    {
                        let acc: js_create::Reader = try!(ip.get_root());
                        let acc_places = try!(acc.get_style());
                        for i in 0..acc_places.len() {
                            let p = acc_places.get(i);
                            vec.push((try!(p.get_key()).into(), try!(p.get_val()).into()));
                        }
                    }
                    // Add it
                    {
                        let mut builder = try!(ip.init_root_from_reader::<js_create::Builder, js_create::Reader>());
                        let mut init = builder.init_style((vec.len() + 1) as u32);
                        let mut i = 0;
                        for p in vec {
                            init.borrow().get(i).set_key(&p.0);
                            init.borrow().get(i).set_val(&p.1);
                            i += 1;
                        }
                        init.borrow().get(i).set_key("order");
                        init.borrow().get(i).set_val(&place);
                    }
                }
                try!(self.ports.send("output", ip));
            }
        }

        Ok(())
    }
}
