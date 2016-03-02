extern crate capnp;

#[macro_use]
extern crate rustfbp;

extern crate piston_window;
extern crate sdl2;
extern crate sdl2_window;

use piston_window::*;
use sdl2_window::Sdl2Window;
use std::thread;

mod contract_capnp {
    include!("ui_conrod.rs");
}
use self::contract_capnp::ui_conrod;

component! {
    ui_conrod_window,
    inputs(input: conrod),
    inputs_array(),
    outputs(output: any, magic: any),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {

        let ip_a = try!(self.ports.recv("input"));

        let window: PistonWindow<(), Sdl2Window> =
        WindowSettings::new("What a mission!", [640, 480])
        .exit_on_esc(true).build().expect("cannot create windows");
        for e in window {
         e.draw_2d(|c, g| {
             clear([1.0; 4], g);
             rectangle([1.0, 0.0, 0.0, 1.0], // red
               [0.0, 0.0, 100.0, 100.0],
               c.transform, g);
         });
     }
     Ok(())
 }
}
