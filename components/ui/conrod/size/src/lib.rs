extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("ui_size.rs");
    include!("ui_create.rs");
}

use contract_capnp::ui_size;
use contract_capnp::ui_create;

component! {
    ui_conrod_size,
    inputs(input: ui_create),
    inputs_array(),
    outputs(output: ui_create),
    outputs_array(),
    option(ui_size),
    acc(ui_button),
    fn run(&mut self) -> Result<()> {
        let mut ip_opt = self.recv_option();
        let mut ip_input = try!(self.ports.recv("input"));

        {
            let mut opt_reader: ui_size::Reader = try!(ip_opt.get_root());
            let mut builder = try!(ip_input.init_root_from_reader::<ui_create::Builder, ui_create::Reader>());

            {
                match try!(opt_reader.get_w().which()) {
                    ui_size::w::Which::None(()) => {
                        try!(builder.borrow().get_size()).get_w().set_none(());
                    },
                    ui_size::w::Which::Fixed(f) => {
                        try!(builder.borrow().get_size()).get_w().set_fixed(f);
                    },
                    ui_size::w::Which::Padded(p) => {
                        try!(builder.borrow().get_size()).get_w().set_padded(p);
                    },

                }
            }
            {
                match try!(opt_reader.get_h().which()) {
                    ui_size::h::Which::None(()) => {
                        try!(builder.borrow().get_size()).get_h().set_none(());
                    },
                    ui_size::h::Which::Fixed(f) => {
                        try!(builder.borrow().get_size()).get_h().set_fixed(f);
                    },
                    ui_size::h::Which::Padded(p) => {
                        try!(builder.borrow().get_size()).get_h().set_padded(p);
                    },

                }
            }
        }

        try!(self.ports.send("output", ip_input));

        Ok(())
    }
}
