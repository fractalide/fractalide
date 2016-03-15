extern crate capnp;

#[macro_use]
extern crate rustfbp;

#[macro_use]
extern crate conrod;

extern crate piston_window;

use std::thread;

mod contract_capnp {
    include!("ui_create.rs");
}
use self::contract_capnp::ui_create;

use conrod::{Labelable, Positionable, Sizeable, Theme, Widget, WidgetIndex, WidgetId, Place};
use piston_window::{EventLoop, Glyphs, PistonWindow, UpdateEvent, WindowSettings};

use std::path::Path;

component! {
    ui_conrod_window,
    inputs(input: any),
    inputs_array(),
    outputs(output: any),
    outputs_array(output: any),
    option(),
    acc(),
    fn run(&mut self) -> Result<()> {
        // Conrod is backend agnostic. Here, we define the `piston_window` backend to use for our `Ui`.
        type Backend = (<piston_window::G2d<'static> as conrod::Graphics>::Texture, Glyphs);
        type Ui = conrod::Ui<Backend>;

        // Construct the window.
        let window: PistonWindow = WindowSettings::new("Click me!", [200, 200])
            .exit_on_esc(true).build().unwrap();

        // construct our `Ui`.
        let mut ui = {
            // let assets = find_folder::Search::KidsThenParents(3, 5)
            //     .for_folder("assets").unwrap();
            let font_path = Path::new("/home/denis/fractalide/fractalide/components/ui/conrod/window/assets/fonts/NotoSans/NotoSans-Regular.ttf");
            let theme = Theme::default();
            let glyph_cache = Glyphs::new(&font_path, window.factory.borrow().clone());
            Ui::new(glyph_cache.unwrap(), theme)
        };

        let mut widgets: HashMap<String, WidgetBuilder> = HashMap::new();
        let mut order_id: Vec<String> = vec![];
        let mut id_manager = IdManager::new();

        // Poll events from the window.
        for event in window.ups(60) {
            let mut ip_a = self.ports.try_recv("input");
            // TODO : update the local state with the IP (the widget, and the order)
            if let Ok(mut ip_a) = ip_a {
                // TODO : receive IP
                if &ip_a.action == "forward_create" || &ip_a.action == "create" {
                    let is_first = &ip_a.action == "create";
                    let mut reader: ui_create::Reader = try!(ip_a.get_root());
                    let id = try!(reader.get_name());
                    let ptr = reader.get_sender();
                    let sender: Box<IPSender> = unsafe { Box::from_raw(ptr as *mut IPSender) };
                    let parent_id = if is_first {
                        "top".into()
                    } else {
                        try!(reader.get_id())
                    };
                    let wid = match try!(try!(reader.get_widget()).which()) {
                        contract_capnp::widget::Which::Button(b) => {
                            let b = try!(b);
                            WidgetType::Button(WButton {
                                label: try!(b.get_label()).into(),
                                enable: b.get_enable(),
                            })
                        },
                        contract_capnp::widget::Which::Lr(lr) => {
                            let lr = try!(lr);
                            let mut vec = vec![];
                            for i in 0..lr.len() {
                                let c = try!(lr.get(i));
                                vec.push(c.into());
                            };
                            vec.sort();
                            WidgetType::Lr(WLr {
                                childrens: vec,
                            })
                        },
                       _ =>  { println!("unreachable heere"); unreachable!() }
                    };
                    let w_w_size = match try!(try!(reader.get_size()).get_w().which()) {
                        contract_capnp::size::w::None => {
                            WHSize::None
                        },
                        contract_capnp::size::w::Fixed(f) => {
                            WHSize::Fixed(f)
                        },
                        contract_capnp::size::w::Padded(p) => {
                            WHSize::Padded(p)
                        }
                    };
                    let w_h_size = match try!(try!(reader.get_size()).get_h().which()) {
                        contract_capnp::size::h::None => {
                            WHSize::None
                        },
                        contract_capnp::size::h::Fixed(f) => {
                            WHSize::Fixed(f)
                        },
                        contract_capnp::size::h::Padded(p) => {
                            WHSize::Padded(p)
                        }
                    };
                    let w_size = WidgetSize {
                        w: w_w_size,
                        h: w_h_size,
                    };
                    let w_x_position = match try!(try!(reader.get_position()).get_x().which()) {
                        contract_capnp::position::x::None => {
                            XPosition::None
                        },
                        contract_capnp::position::x::Right(r) => {
                            XPosition::Right(r)
                        },
                        contract_capnp::position::x::Left(l) => {
                            XPosition::Left(l)
                        },
                    };
                    let w_y_position = match try!(try!(reader.get_position()).get_y().which()) {
                        contract_capnp::position::y::None => {
                            YPosition::None
                        },
                        contract_capnp::position::y::Top(t) => {
                            YPosition::Top(t)
                        },
                        contract_capnp::position::y::Bottom(b) => {
                            YPosition::Bottom(b)
                        },
                    };
                    let w_position = WidgetPosition {
                        x: w_x_position,
                        y: w_y_position,
                    };
                    let sender = sender;
                    let w = WidgetBuilder {
                        sort: wid,
                        parent_id: parent_id.into(),
                        size: w_size,
                        position: w_position,
                        sender: sender,
                    };
                    widgets.insert(id.into(), w);

                    // Create widgets order
                    // TODO : check for better solution
                    order_id = widgets.keys().map(|k| { k.clone() }).collect();
                    order_id.sort_by(|a, b| {
                        let a = widgets.get(a).unwrap().parent_id.split("-").count();
                        let b = widgets.get(b).unwrap().parent_id.split("-").count();
                        a.cmp(&b)
                    });
                }
            }



              // if &ip_a.action == "create" {
              //     let reader: generic_u64::Reader = try!(ip_a.get_root());
              //     let ptr = reader.get_number();
              //     let sender: Box<IPSender> = unsafe { Box::from_raw(ptr as *mut IPSender) };
              //     button = Some(*sender);
              // }
            ui.handle_event(&event);
            let mut count = 0;
            event.update(|_| ui.set_widgets(|ref mut ui| {

                // Create the basic canvas
                conrod::Canvas::new().set(id_manager.get("top"), ui);

                // TODO : generate the widgets in the right order
                for i in &order_id {
                    let widget = widgets.get(i);
                    if let Some(widget) = widget {
                        match widget.sort {
                            WidgetType::Button(ref button) => {
                                let mut b = conrod::Button::new()
                                    .label(&button.label)
                                    .react(|| {
                                        let mut ip = IP::new();
                                        ip.action = "button_clicked".into();
                                        let _ = Ports::send_sender(&widget.sender, ip);
                                    })
                                    .enabled(button.enable);
                                b = set_size(b, &widget, &mut id_manager);
                                b = set_position(b, &widget, &mut id_manager);
                                b.set(id_manager.get(&i), ui);
                            },
                            WidgetType::Lr(ref lr) => {
                                let mut vec = vec![];
                                for c in &lr.childrens {
                                    if let WidgetIndex::Public(id) = id_manager.get(c) {
                                        vec.push((id, conrod::Canvas::new()));
                                    }
                                }
                                let mut c = conrod::Canvas::new()
                                    .flow_right(&vec[..]);
                                c = set_size(c, &widget, &mut id_manager);
                                c = set_position(c, &widget, &mut id_manager);
                                c.set(id_manager.get(&i), ui);
                            },
                        }
                    }
                }

                // Generate the ID for the Button COUNTER.
                // widget_ids!(C, CANVAS, CC1, CC2, COUNTER1, COUNTER2);


                // conrod::Canvas::new().set(C, ui);
                // conrod::Canvas::new()
                //     .middle_of(C)
                //     .flow_right(&[
                //         (CC1, conrod::Canvas::new()),
                //         (CC2, conrod::Canvas::new()),
                //         ])
                //     .set(CANVAS, ui);
                // // Create a background canvas upon which we'll place the button.
                // // conrod::Canvas::new().pad(40.0).set(CANVAS, ui);

                // // Draw the button and increment `count` if pressed.
                // conrod::Button::new()
                //     .middle_of(CC1)
                //     //.align_right_of(CC1)
                //     //.align_middle_y_of(CC1)
                //     //.w_h(80.0, 80.0)
                //     .label(&count.to_string())
                //     .react(|| {
                //         count += 1;
                //         println!("button1 clicked")
                //         })
                //     .set(COUNTER1, ui);

                // conrod::Button::new()
                //     .middle_of(CC2)
                //     //.align_left_of(CC2)
                //     //.align_middle_y_of(CC2)
                //     // .w_h(80.0, 8//0.0)
                //     .label(&count.to_string())
                //     .react(|| {
                //         count += 1;
                //         println!("button2 clicked")
                //         })
                //     .set(COUNTER2, ui);
            }));
            event.draw_2d(|c, g| ui.draw_if_changed(c, g));
        }
     Ok(())
 }
}

struct WidgetBuilder {
    sort: WidgetType,
    parent_id: String,
    size: WidgetSize,
    position: WidgetPosition,
    sender: Box<IPSender>,
}

struct WidgetSize {
    w: WHSize,
    h: WHSize,
}

enum WHSize {
    None, Fixed(f64), Padded(f64),
}

struct WidgetPosition {
    x: XPosition,
    y: YPosition,
}

enum XPosition {
    None,
    Right(f64),
    Left(f64),
}

enum YPosition {
    None,
    Top(f64),
    Bottom(f64),
}

fn set_size<T: Sizeable>(widget: T, size: &WidgetBuilder, id_manager: &mut IdManager) -> T {
    let widget = match size.size.w {
        WHSize::None => {
            widget.w_of(id_manager.get(&size.parent_id))
        },
        WHSize::Fixed(f) => {
            widget.w(f)
        },
        WHSize::Padded(p) => {
            widget.padded_w_of(id_manager.get(&size.parent_id), p)
        }
    };
    match size.size.h {
        WHSize::None => {
            widget.h_of(id_manager.get(&size.parent_id))
        },
        WHSize::Fixed(f) => {
            widget.h(f)
        },
        WHSize::Padded(p) => {
            widget.padded_h_of(id_manager.get(&size.parent_id), p)
        }
    }
}

fn set_position<T: Positionable>(widget: T, position: &WidgetBuilder, id_manager: &mut IdManager) -> T {
    let widget = match position.position.x {
        XPosition::None => {
            widget.x_place_on(id_manager.get(&position.parent_id), Place::Middle)
        },
        XPosition::Left(l) => {
            widget.x_place_on(id_manager.get(&position.parent_id), Place::Start(Some(l)))
        },
        XPosition::Right(r) => {
            widget.x_place_on(id_manager.get(&position.parent_id), Place::End(Some(r)))
        }
    };
    match position.position.y {
        YPosition::None => {
            widget.y_place_on(id_manager.get(&position.parent_id), Place::Middle)
        },
        YPosition::Top(t) => {
            widget.y_place_on(id_manager.get(&position.parent_id), Place::Start(Some(t)))
        },
        YPosition::Bottom(b) => {
            widget.y_place_on(id_manager.get(&position.parent_id), Place::End(Some(b)))
        }
    }

}

enum WidgetType {
    Button(WButton),
    Lr(WLr),
}

struct WButton {
    label: String,
    enable: bool,
}

struct WLr {
    childrens: Vec<String>,
}


struct IdManager {
    store: HashMap<String, WidgetIndex>,
    next: usize,
}

impl IdManager {
    fn new() -> Self {
        IdManager {
            store: HashMap::new(),
            next: 0,
        }
    }

    fn get(&mut self, name: &str) -> WidgetIndex {
        if !self.store.contains_key(name) {
            let n_id = WidgetIndex::Public(WidgetId(self.next));
            self.next += 1;
            self.store.insert(name.into(), n_id);
        }

        match { self.store.get(name) } {
            Some(id) => { id.clone() },
            None => { unreachable!() },
        }
    }
}
