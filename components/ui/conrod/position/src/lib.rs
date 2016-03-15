extern crate capnp;

#[macro_use]
extern crate rustfbp;

use std::thread;

mod contract_capnp {
    include!("ui_position.rs");
    include!("ui_create.rs");
}

use contract_capnp::ui_position;
use contract_capnp::ui_create;

component! {
    ui_conrod_position,
    inputs(input: ui_create),
    inputs_array(),
    outputs(output: ui_create),
    outputs_array(),
    option(ui_position),
    acc(ui_button),
    fn run(&mut self) -> Result<()> {
        let mut ip_opt = self.recv_option();
        let mut ip_input = try!(self.ports.recv("input"));

        {
            let mut opt_reader: ui_position::Reader = try!(ip_opt.get_root());
            let mut builder = try!(ip_input.init_root_from_reader::<ui_create::Builder, ui_create::Reader>());

            {
                match try!(opt_reader.get_x().which()) {
                    ui_position::x::Which::None(()) => {
                        try!(builder.borrow().get_position()).get_x().set_none(());
                    },
                    ui_position::x::Which::Right(r) => {
                        try!(builder.borrow().get_position()).get_x().set_right(r);
                    },
                    ui_position::x::Which::Left(l) => {
                        try!(builder.borrow().get_position()).get_x().set_left(l);
                    },

                }
            }
            {
                match try!(opt_reader.get_y().which()) {
                    ui_position::y::Which::None(()) => {
                        try!(builder.borrow().get_position()).get_y().set_none(());
                    },
                    ui_position::y::Which::Top(t) => {
                        try!(builder.borrow().get_position()).get_y().set_top(t);
                    },
                    ui_position::y::Which::Bottom(b) => {
                        try!(builder.borrow().get_position()).get_y().set_bottom(b);
                    },

                }
            }
        }

        try!(self.ports.send("output", ip_input));

        Ok(())
    }
}
