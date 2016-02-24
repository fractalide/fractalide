extern crate capnp;

#[macro_use]
extern crate rustfbp;


extern crate piston_window;

// use conrod::{Labelable, Positionable, Sizeable, Theme, Ui, Widget};
// use piston_window::{EventLoop, Glyphs, PistonWindow, UpdateEvent, WindowSettings};
use piston_window::*;

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

        let window: PistonWindow =
            WindowSettings::new("Hello Piston!", [640, 480])
            .exit_on_esc(true).build().expect("cannot create windows");
        for e in window {
            e.draw_2d(|c, g| {
                clear([1.0; 4], g);
                rectangle([1.0, 0.0, 0.0, 1.0], // red
                          [0.0, 0.0, 100.0, 100.0],
                          c.transform, g);
            });
        }

        // // Construct the window.
        // let window: PistonWindow =
            // WindowSettings::new("Text Demo", [1080, 720])
            // .exit_on_esc(true).build().unwrap();
// 
            // // construct our `Ui`.
        // let mut ui = {
            // let assets = find_folder::Search::KidsThenParents(3, 5)
                // .for_folder("assets").unwrap();
            // let font_path = assets.join("fonts/NotoSans/NotoSans-Regular.ttf");
            // let theme = Theme::default();
            // let glyph_cache = Glyphs::new(&font_path, window.factory.borrow().clone());
            // Ui::new(glyph_cache.unwrap(), theme)
      // };
// 
        // let mut count = 0;
// 
        // // Poll events from the window.
        // for event in window.ups(60) {
            // ui.handle_event(&event);
            // event.update(|_| ui.set_widgets(|ui| {
// 
                // // Generate the ID for the Button COUNTER.
                // widget_ids!(CANVAS, COUNTER);
// 
                // // Create a background canvas upon which we'll place the button.
                // conrod::Canvas::new().pad(40.0).set(CANVAS, ui);
// 
                // // Draw the button and increment `count` if pressed.
                // conrod::Button::new()
                    // .middle_of(CANVAS)
                    // .w_h(80.0, 80.0)
                    // .label(&count.to_string())
                    // .react(|| count += 1)
                    // .set(COUNTER, ui);
            // }));
            // event.draw_2d(|c, g| ui.draw_if_changed(c, g));
        // }

        // let _ = self.ports.send_action("output", ip_a);

        // let mut new_ip = IP::new();
        // new_ip.origin = "-button".to_string();
        // self.ports.send("magic", new_ip);

        // let mut new_ip = IP::new();
        // new_ip.origin = "-button".to_string();
        // self.ports.send("magic", new_ip);

        // let mut new_ip = IP::new();
        // new_ip.origin = "-button".to_string();
        // new_ip.action = "button_clicked".into();
        // self.ports.send("magic", new_ip);

        Ok(())
    }
}
